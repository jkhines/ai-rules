#!/usr/bin/env python3
"""Stop hook: check Claude's own last message against the mechanical writing rules.

Reads the hook payload on stdin, finds this session's transcript, extracts the last assistant
message, and checks it against the rules in CLAUDE.md and the humanize skill that a program can
decide. Blocking failures come back to the model as a rewrite instruction, so conformance needs
no user interaction. Softer signals come back as a one-line note.

Vocabulary is read live from SKILL.md so the hook and the skill never drift apart. Pure standard
library, so the hook adds no install step and no network call.
"""
import json
import re
import statistics
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILL = REPO / "skills/humanize/SKILL.md"
STATE = Path.home() / ".claude/hooks/.prose-check-state.json"
PROJECTS = Path.home() / ".claude/projects"
MAX_CONSECUTIVE_BLOCKS = 2    # Two rewrites, then the turn passes so a bad rule cannot trap it.
POLL_ATTEMPTS = 8             # The transcript write races the hook, so wait for a fresh timestamp.
POLL_INTERVAL_SECONDS = 0.25

SENTENCE_WORD_CAP = 25
PARAGRAPH_SENTENCE_CAP = 5
TIER2_PARAGRAPH_CLUSTER = 2   # The skill flags Tier 2 words only when two share a paragraph.
TIER3_DENSITY = 0.03          # The skill flags Tier 3 words only at roughly 3% of the words.


# --------------------------------------------------------------------------- input

def read_last_assistant(session_id):
    """(text, timestamp) of the most recent assistant message, or (None, None)."""
    matches = list(PROJECTS.glob(f"*/{session_id}.jsonl"))
    if not matches:
        return None, None
    text = stamp = None
    with matches[0].open() as fh:
        for line in fh:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            if entry.get("type") != "assistant":
                continue
            blocks = entry.get("message", {}).get("content", [])
            body = "\n".join(b["text"] for b in blocks if isinstance(b, dict) and b.get("type") == "text")
            if body.strip():
                text, stamp = body, entry.get("timestamp")
    return text, stamp


def last_assistant_text(session_id, already_checked):
    """Wait for a message newer than the one we last blocked on, then return it.

    The transcript write races the hook, so a naive read returns the previous attempt and
    blocks twice on text the model already fixed. Poll briefly for a fresh timestamp; if none
    arrives, return None so the turn passes rather than blocking on stale text.
    """
    settled = None
    for _ in range(POLL_ATTEMPTS):
        text, stamp = read_last_assistant(session_id)
        if text is None:
            return None
        if stamp != already_checked and stamp == settled:
            return text          # Same entry twice running, so the turn has finished writing.
        settled = stamp
        time.sleep(POLL_INTERVAL_SECONDS)
    return None


# ----------------------------------------------------------------------- text prep

def prose(text):
    """Drop fenced code, tables, inline code spans, quotations, and headings. Keep body prose.

    Code spans and block quotations are the escape hatch. The humanize skill leaves technical
    artifacts and other people's words alone, so anything inside them stays unchecked.
    """
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    text = re.sub(r"`[^`]*`", "", text)
    kept = [ln for ln in text.split("\n") if not ln.strip().startswith(("|", "#", ">"))]
    return "\n".join(kept)


def sentences(text, want_flags=False):
    """Sentence-sized units. A list item is its own unit even without terminal punctuation.

    With want_flags, yields (unit, from_list_item) so callers can exempt list items from
    rules that assume a full sentence.
    """
    out = []
    for line in re.sub(r"\*\*|\*", "", text).split("\n"):
        listed = bool(re.match(r"^\s*(?:[-*]|\d+\.)\s", line))
        block = re.sub(r"^\s*(?:[-*]|\d+\.)\s*", "", line).strip()
        if not block:
            continue
        for unit in re.split(r"(?<=[.!?])\s+", block):
            if unit.strip():
                out.append((unit.strip(), listed) if want_flags else unit.strip())
    return out


def blocks_of_text(text):
    """Blank-line separated blocks, list items included, for per-paragraph counting."""
    return [b.strip() for b in re.sub(r"\*\*|\*", "", text).split("\n\n") if b.strip()]


def paragraphs(text):
    """Sentence counts for real paragraphs. List blocks are excluded; they are not prose."""
    counts = []
    for block in blocks_of_text(text):
        if re.match(r"^\s*(?:[-*]|\d+\.)\s", block):
            continue
        counts.append(len(re.split(r"(?<=[.!?])\s+", block)))
    return counts


def syllables(word):
    word = re.sub(r"[^a-z]", "", word.lower())
    if not word:
        return 0
    groups = len(re.findall(r"[aeiouy]+", word))
    if word.endswith("e") and not word.endswith(("le", "ee")) and groups > 1:
        groups -= 1
    return max(groups, 1)


def fk_grade(sents):
    words = [w for s in sents for w in s.split()]
    if not words or not sents:
        return 0.0
    syl = sum(syllables(w) for w in words)
    return round(0.39 * (len(words) / len(sents)) + 11.8 * (syl / len(words)) - 15.59, 1)


# ---------------------------------------------------------------------- vocabulary

TIER_HEADINGS = {
    "tier 1": "tier1",
    "tier 2": "tier2",
    "tier 3": "tier3",
    "words to avoid": "avoid",
}


def term_pattern(term):
    """Match the term and its ordinary inflections. The skill asks for inflected forms too."""
    if not term.isalpha():
        return re.compile(r"\b" + re.escape(term) + r"\b", re.I)
    branches = [re.escape(term) + r"(?:s|es|d|ed|ing|ly)?"]
    if term.endswith("e"):
        # "utilize" also has to catch "utilizing", where the trailing e drops.
        branches.append(re.escape(term[:-1]) + r"(?:ing|ed|es)")
    return re.compile(r"\b(?:" + "|".join(branches) + r")\b", re.I)


def skill_vocabulary():
    """Replacement-table terms from SKILL.md, grouped by tier and by whether they are qualified.

    A left-column entry carrying a parenthetical condition ("deploy (unless military or
    software)") has an exception no program can decide, so it becomes a warning rather than a
    blocking failure.
    """
    groups = {name: {"plain": {}, "qualified": {}} for name in set(TIER_HEADINGS.values())}
    if not SKILL.exists():
        return groups
    tier = None
    for line in SKILL.read_text().splitlines():
        line = line.strip()
        if line.startswith("#"):
            heading = line.lstrip("#").strip().lower()
            tier = next((v for k, v in TIER_HEADINGS.items() if k in heading), None)
            continue
        if tier is None or not line.startswith("|"):
            continue
        if line.startswith(("|---", "| Replace", "| Word")):
            continue
        raw = line.split("|")[1].strip()
        bucket = "qualified" if "(" in raw else "plain"
        for part in re.sub(r"\(.*?\)", "", raw).split("/"):
            part = part.strip().strip("`").lower()
            if len(part) > 2:
                groups[tier][bucket][part] = term_pattern(part)
    return groups


# -------------------------------------------------------------------------- checks

# Negative parallelism: a negated clause immediately answered by its positive twin.
NEG_PARALLEL = {
    "verb-echo": re.compile(
        r"\b(?:it|this|that|they|we|you)\s+(?:do(?:es)?n'?t|did\s?n'?t|won'?t|is\s?n'?t|are\s?n'?t|was\s?n'?t)"
        r"\s+(\w{3,})\b[^.;!?]{0,70}?[,;]\s*(?:it|this|that|they|we|you)\s+\1(?:s|es)?\b", re.I),
    "neg-then-its": re.compile(
        r"\b(?:is\s?n'?t|is not|are\s?n'?t|are not|was\s?n'?t|it'?s not|this is\s?n'?t)\b"
        r"[^.;!?]{1,70}?[,;-]\s*(?:it'?s|it is|they'?re|they are|rather)\b", re.I),
    "not-but": re.compile(r"\bnot\s+(?:only\s+|just\s+|merely\s+)?[^.;!?]{1,70}?,?\s+but\b", re.I),
    "reversed": re.compile(
        r"(?:,|\band)\s+not\s+(?:only\s+|just\s+|merely\s+)?\w[\w\s'-]{2,45}?(?=[.;,!?]|$)", re.I | re.M),
}

# --------------------------------------------------------------------- fragments
#
# Finding a fragment properly needs part-of-speech tagging, which the standard library does not
# have. These rules trade recall for precision instead: a verb lexicon plus generous verb-like
# suffixes, so anything that might carry a verb is left alone. A false positive costs a forced
# rewrite, and a miss costs nothing but a fragment, so the trade runs that way on purpose.
FINITE_VERBS = set("""is are was were am be been being has have had do does did can could will
would shall should may might must""".split())
SUBJECT_PRONOUNS = set("i you we they he she it there here who".split())
LEADING_PHRASE_OK = set("""after before when if since while although though because unless once
until whenever wherever as for in on at by with to from during despite given without under over
where whether than that so and but""".split())
RELATIVIZERS = set("which who whom whose".split())

VERB_STEMS = set("""accept add address adjust allow apply ask assume avoid become begin block
break bring build call carry catch cause change check choose clear come consider contain continue
cost cover create cut decide define delete depend describe design detect determine drop enable
end enforce enter exist expect explain fail fall feel fetch fill find finish fire fit fix flag
follow force forget generate get give grow handle happen help hide hit hold hook ignore include
increase indicate inject install keep know land lead learn leave let limit link list live load
look lose make map mark match matter mean meet miss move name need note notice offer open order
pass pay pick place plan play point post prefer prevent print produce protect prove provide pull
push put raise reach read receive reduce refer register relate release remain remember remove
rename render repeat replace report request require reset resolve return reveal rewrite run save
say see seem select send serve set settle share show sign sit skip solve sort sound speak spend
split stand start state stay stop store strip suggest support suppose take talk teach tell tend
test think throw touch track train treat trigger try turn understand update use verify wait walk
want warn watch win work wrap write yield""".split())

# Irregular past and participle forms, which no suffix rule reaches.
IRREGULAR_VERBS = set("""became began broke brought built came caught chose came dealt did done
drove fell felt found gave gone got grew heard held kept knew laid led left lost made meant met
paid put ran read run said said sat saw seen sent set shown showed sold spent split spoke stood
taken took taught thought told took understood went wrote written""".split())

# Any word carrying one of these endings is treated as a possible verb, which keeps the detector
# quiet around vocabulary the lexicon above does not know.
VERB_LIKE = ("ing", "ed", "es", "ate", "ates", "ated", "ize", "izes", "ized", "ise", "ises",
             "ised", "ify", "ifies", "ified")


def has_verb(tokens):
    for token in tokens:
        word = token.lower()
        if word in FINITE_VERBS or word in VERB_STEMS or word in IRREGULAR_VERBS:
            return True
        for suffix in ("s", "es", "ed", "ing", "d"):
            stem = word[: -len(suffix)]
            if word.endswith(suffix) and (stem in VERB_STEMS or stem + "e" in VERB_STEMS):
                return True
        if len(word) > 5 and word.endswith(VERB_LIKE):
            return True
    return False


def is_fragment(sentence):
    """The comma-led shape: a short opening segment carrying no verb."""
    s = re.sub(r"^\s*(?:[-*]|\d+\.)\s*", "", sentence).strip().rstrip(".!?:")
    if "," not in s:
        return False
    tokens = re.findall(r"[A-Za-z']+", s.split(",")[0].strip())
    if not tokens or len(tokens) > 4:
        return False  # Long enough that a lexical verb this list does not know is likely present.
    if len(tokens) == 1:
        return False  # A lone word before a comma heads a list: "Fragments, analogies, and prose".
    if tokens[0].lower() in SUBJECT_PRONOUNS:
        return False  # "You see both" and "I recommend X" carry a lexical verb this list lacks.
    if tokens[0].lower() in LEADING_PHRASE_OK:
        return False  # Leading subordinate or prepositional phrase, which is correct grammar.
    if has_verb(tokens):
        return False
    if re.search(r"(?:ed|es|s|ing)$", tokens[-1].lower()):
        return False  # Final word inflects like a verb, so assume the segment has one.
    return True


def fragment_reason(sentence):
    """Why the sentence reads as a fragment, or None when it reads as a whole sentence."""
    s = re.sub(r"^\s*(?:[-*]|\d+\.)\s*", "", sentence).strip()
    if s.endswith("?"):
        return None
    tokens = re.findall(r"[A-Za-z']+", s.rstrip(".!:;"))
    if not tokens:
        return None
    if len(tokens) > 1 and tokens[0].lower() in RELATIVIZERS:
        return "opens with a relative pronoun and stands alone"
    if len(tokens) <= 12 and not has_verb(tokens):
        return "no verb"
    if is_fragment(sentence):
        return "no verb before the comma"
    return None


# ------------------------------------------------------------ analogy and density

# Analogies and similes. The skill asks for the mechanism named directly instead.
ANALOGY = {
    "simile": re.compile(r"\b(?:like|as)\s+(?:a|an)\s+\w+", re.I),
    "as-if": re.compile(r"\bas (?:if|though)\b", re.I),
    "invitation": re.compile(r"\b(?:think of|imagine|picture)\s+(?:it|this|that|a|an|the)\b", re.I),
    "equivalence": re.compile(
        r"\b(?:akin to|analogous to|the equivalent of|metaphorically|so to speak|in a sense)\b", re.I),
    "reduction": re.compile(
        r"\bis\s+(?:basically|essentially|just|simply|nothing more than)\s+(?:a|an)\b", re.I),
}

# Nouns built out of verbs, which lengthen a sentence without adding to it. The -ance and -ence
# endings are left out on purpose: they collide with verb forms such as "references".
NOMINALIZATION = re.compile(r"\b\w{5,}(?:tions?|sions?|ments?|ities|ity)\b", re.I)
NOMINALIZATION_SHARE = 0.06
NOMINALIZATION_FLOOR = 5      # A short reply can carry one of these without reading as dense.

# A run of content words with no function word between them, which the reader has to unpack.
FUNCTION_WORDS = set("""a an the of to in for on at by with and or but nor is are was were am be
been being has have had do does did can could will would shall should may might must not no as
from that this these those it its their they there than then so if into over under about which
who whose when while because although since until per via each any all both more most other
same such only just also very where how why what through throughout among amongst toward towards
during before after above below beneath between within without against across along around
behind beyond beside near off out up down upon unless though whether either neither own cannot
onto out inside outside despite besides plus minus once here now yet still even ever never""".split())
NOUN_STACK_RUN = 5

LONG_WORD_SHARE = 0.25
GRADE_WARN = 10
GRADE_BLOCK = 12
GRADE_FLOOR_WORDS = 60        # Flesch-Kincaid swings wildly on a couple of sentences.


def noun_stacks(sents):
    """Runs of NOUN_STACK_RUN lowercase nouns and modifiers with nothing between them.

    A verb, a function word, a capitalized word, or any punctuation ends the run. A stack is
    nouns piled on nouns, so anything that could be a verb means the reader has a clause.
    """
    found = []
    for sentence in sents:
        run = []
        for token in re.findall(r"[A-Za-z'-]+|[^A-Za-z'\s-]", sentence):
            word = token.lower()
            if (not token[0].isalpha() or word in FUNCTION_WORDS or not token.islower()
                    or has_verb([word])):
                run = []
                continue
            run.append(token)
            if len(run) >= NOUN_STACK_RUN:
                found.append(" ".join(run))
                run = []
    return found


def density_findings(body, sents):
    """(blocking, warnings) for the signals that make prose dense rather than wrong."""
    blocking, warnings = [], []
    words = [w for s in sents for w in s.split()]
    if not words:
        return blocking, warnings

    nouns = sorted(set(m.group(0).lower() for m in NOMINALIZATION.finditer(body)))
    count = len(NOMINALIZATION.findall(body))
    if count >= NOMINALIZATION_FLOOR and count / len(words) >= NOMINALIZATION_SHARE:
        blocking.append(f"{count} nouns built from verbs in {len(words)} words. "
                        f"Break them back into verbs: {', '.join(nouns[:8])}")

    for stack in noun_stacks(sents)[:4]:
        blocking.append(f"{NOUN_STACK_RUN} content words with nothing between them: \"{stack}\". "
                        "Rewrite the stack as a clause.")

    grade = fk_grade(sents)
    if len(words) < GRADE_FLOOR_WORDS:
        pass                      # Too short for the score to mean anything.
    elif grade > GRADE_BLOCK:
        blocking.append(f"reading grade {grade} (estimated, cap {GRADE_BLOCK}). "
                        "Shorten the sentences and use shorter words.")
    elif grade > GRADE_WARN:
        warnings.append(f"reading grade {grade} (estimated, target {GRADE_WARN} or below)")

    long_words = [w for w in words if syllables(w) >= 3]
    if long_words and len(long_words) / len(words) >= LONG_WORD_SHARE:
        warnings.append(f"{len(long_words)} of {len(words)} words carry three syllables or more")
    return blocking, warnings


# Pronouns standing in for a whole idea instead of a named actor.
VAGUE_REFERENT = re.compile(
    r"\b(?:say|says|mean|means|do|does|fix|fixes|update|updates|write|writes)\s+(?:this|that|it)\b(?!\s+\w)", re.I)

# A label welded to a sentence, which the skill replaces with one grammatical sentence.
LABEL_VALUE = re.compile(r"^\**[A-Z][A-Za-z][A-Za-z ]{1,22}:\**\s+[A-Z]", re.M)

EMOJI = re.compile(
    "[\U0001F300-\U0001FAFF\U00002600-\U000027BF\U0001F000-\U0001F2FF\U00002190-\U00002199\U0000FE0F]")

HEDGES = ["perhaps", "could potentially", "it's important to note", "it is important to note",
          "it's worth noting", "it is worth noting", "to be clear", "arguably", "somewhat",
          "fairly", "rather more", "in terms of", "at the end of the day"]
TRANSITIONS = ["moreover", "furthermore", "additionally", "that being said", "in conclusion",
               "in summary", "when it comes to", "notably", "interestingly", "importantly"]
CHATBOT = ["i hope this helps", "great question", "certainly!", "feel free to reach out",
           "let me know if you need"]


def vocabulary_findings(body):
    """(blocking, warnings) for the replacement tables, each tier judged by its own trigger."""
    groups = skill_vocabulary()
    blocking, warnings = [], []

    blocked = set()
    for tier in ("tier1", "avoid"):
        hits = sorted(t for t, p in groups[tier]["plain"].items() if p.search(body))
        if hits:
            label = "Tier 1 words" if tier == "tier1" else "words to avoid"
            blocking.append(f"{label} to replace: {', '.join(hits[:12])}")
        blocked.update(hits)

    # A parenthetical condition in the table has an exception no program can decide.
    soft = {t for tier in ("tier1", "avoid") for t, p in groups[tier]["qualified"].items()
            if t not in blocked and p.search(body)}
    if soft:
        warnings.append("conditional term(s), replace unless the table's exception applies: "
                        + ", ".join(sorted(soft)[:10]))

    tier2 = {**groups["tier2"]["plain"], **groups["tier2"]["qualified"]}
    for block in blocks_of_text(body):
        cluster = sorted(t for t, p in tier2.items() if p.search(block))
        if len(cluster) >= TIER2_PARAGRAPH_CLUSTER:
            warnings.append(f"Tier 2 cluster in one paragraph: {', '.join(cluster[:8])}")

    words = max(len(body.split()), 1)
    tier3 = {**groups["tier3"]["plain"], **groups["tier3"]["qualified"]}
    dense = sorted(t for t, p in tier3.items() if p.search(body))
    if dense and sum(len(p.findall(body)) for p in tier3.values()) / words >= TIER3_DENSITY:
        warnings.append(f"Tier 3 density above {int(TIER3_DENSITY * 100)}%: {', '.join(dense[:8])}")
    return blocking, warnings


def run_checks(text):
    body = prose(text)
    sents = sentences(body)
    if not sents:
        return [], []
    blocking, warnings = [], []
    low = body.lower()

    long_sents = [(len(s.split()), s) for s in sents if len(s.split()) > SENTENCE_WORD_CAP]
    for n, s in sorted(long_sents, reverse=True)[:5]:
        blocking.append(f"{n}-word sentence (cap {SENTENCE_WORD_CAP}): \"{s[:110]}\"")

    dashes = body.count("—") + len(re.findall(r"(?<=\w)--(?=\w|\s)", body))
    if dashes:
        blocking.append(f"{dashes} em dash(es). Use a comma, a period, or two sentences.")

    found_emoji = sorted(set(EMOJI.findall(text)))
    if found_emoji:
        blocking.append(f"emoji present: {' '.join(found_emoji)}. Remove them.")

    tics = [t for t in CHATBOT if t in low]
    if tics:
        blocking.append(f"chatbot tic(s) to delete: {', '.join(tics)}")

    fillers = [t for t in TRANSITIONS if t in low]
    if fillers:
        blocking.append(f"filler transition(s) to cut or restructure: {', '.join(fillers)}")

    for name, pattern in ANALOGY.items():
        for m in pattern.finditer(body):
            blocking.append(f"analogy [{name}]: \"{m.group(0).strip()}\". "
                            "Name the mechanism directly instead of comparing it to something else.")

    for s, listed in sentences(body, want_flags=True):
        if listed:
            continue  # A bullet reads on from its lead-in, so it need not be a whole sentence.
        reason = fragment_reason(s)
        if reason:
            blocking.append(f"fragment ({reason}): \"{s[:90]}\". Write a whole sentence.")

    density_blocking, density_warnings = density_findings(body, sents)
    blocking += density_blocking
    warnings += density_warnings

    vocab_blocking, vocab_warnings = vocabulary_findings(body)
    blocking += vocab_blocking
    warnings += vocab_warnings

    for n in [c for c in paragraphs(body) if c > PARAGRAPH_SENTENCE_CAP]:
        warnings.append(f"{n}-sentence paragraph (cap {PARAGRAPH_SENTENCE_CAP})")

    for name, pattern in NEG_PARALLEL.items():
        for m in pattern.finditer(body):
            warnings.append(f"negative parallelism [{name}]: \"{m.group(0).strip()[:80]}\"")

    for m in LABEL_VALUE.finditer(body):
        warnings.append(f"label welded to a sentence: \"{m.group(0).strip()[:60]}\"")

    for m in VAGUE_REFERENT.finditer(body):
        warnings.append(f"pronoun with no named actor: \"{m.group(0)}\"")

    hedged = [t for t in HEDGES if t in low]
    if hedged:
        warnings.append("hedging: " + ", ".join(hedged))

    lens = [len(s.split()) for s in sents]
    warnings.append(f"stats: {len(sents)} sentences, longest {max(lens)} words, "
                    f"mean {round(statistics.mean(lens), 1)}, grade {fk_grade(sents)}")
    return blocking, warnings


# --------------------------------------------------------------------------- state

def load_state():
    try:
        return json.loads(STATE.read_text())
    except (OSError, json.JSONDecodeError):
        return {}


def consecutive_blocks(session_id, blocked, stamp=None):
    """Track repeated blocks so a bad rule cannot trap the session."""
    state = load_state()
    prior = state.get(session_id) or {}
    count = prior.get("blocks", 0) + 1 if blocked else 0
    state[session_id] = {"blocks": count, "stamp": stamp or prior.get("stamp")}
    if len(state) > 200:
        state = {session_id: state[session_id]}
    try:
        STATE.parent.mkdir(parents=True, exist_ok=True)
        STATE.write_text(json.dumps(state))
    except OSError:
        pass
    return count


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return
    session_id = payload.get("session_id") or payload.get("sessionId")
    if not session_id:
        return

    prior_stamp = (load_state().get(session_id) or {}).get("stamp")
    text = last_assistant_text(session_id, prior_stamp)
    if not text:
        return
    _, stamp = read_last_assistant(session_id)

    blocking, warnings = run_checks(text)
    if not blocking:
        consecutive_blocks(session_id, False, stamp)
        return

    attempt = consecutive_blocks(session_id, True, stamp)
    if attempt > MAX_CONSECUTIVE_BLOCKS:
        print(json.dumps({"systemMessage": f"prose-check: {len(blocking)} unfixed issue(s), letting the turn through"}))
        return

    lines = [f"Your last message failed the prose check (attempt {attempt} of {MAX_CONSECUTIVE_BLOCKS}).",
             "Rewrite the message so it passes, then send the corrected version only.",
             "Say nothing about this check to the user, and add no apology or explanation.",
             "Put a technical term, a quoted word, or a flagged word you must keep inside backticks.",
             "", "Must fix:"]
    lines += [f"  - {b}" for b in blocking]
    if warnings:
        lines += ["", "Also consider:"] + [f"  - {w}" for w in warnings]
    print(json.dumps({"decision": "block", "reason": "\n".join(lines)}))


if __name__ == "__main__":
    main()
