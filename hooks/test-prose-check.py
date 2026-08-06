#!/usr/bin/env python3
"""Fixtures for prose-check.py. Run it directly: python3 hooks/test-prose-check.py

The fragment, analogy, and density rules trade recall for precision, so the negative fixtures
matter more than the positive ones. A false positive forces a rewrite the writer cannot satisfy.
Every negative fixture is ordinary technical prose that has to pass untouched.
"""
import importlib.util
import sys
from pathlib import Path

spec = importlib.util.spec_from_file_location("prose_check", Path(__file__).with_name("prose-check.py"))
pc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pc)

# (label, text, substring that must appear in a blocking finding)
POSITIVE = [
    ("fragment, verbless", "The change is in. Direct and specific.", "fragment"),
    ("fragment, relative pronoun", "The hook fires twice. Which is why the count is wrong.", "fragment"),
    ("fragment, comma-led", "Pure standard library, so there is no install step.", "fragment"),
    ("fragment, noun phrase", "I shipped it. A small and tidy outcome.", "fragment"),
    ("analogy, simile", "A connection pool works like a taxi rank at a station.", "analogy"),
    ("analogy, invitation", "Think of it as a waiting room for open sockets.", "analogy"),
    ("analogy, reduction", "The scheduler is essentially a queue with priorities.", "analogy"),
    ("analogy, as-if", "The reader behaves as if the file were missing.", "analogy"),
    ("density, nominalization",
     "The implementation of the migration required verification of the configuration, "
     "coordination of the deployment, and confirmation of the reconciliation.", "verbs"),
    ("density, noun stack",
     "We changed the output token budget cap enforcement setting yesterday.", "content words"),
    # A reading grade is a whole-text measure, so this fixture clears GRADE_FLOOR_WORDS.
    ("density, grade",
     "The instrumentation subsystem propagates parameters through an intermediary abstraction. "
     "Subsequent revalidation necessitates an exhaustive traversal of antecedent dependencies. "
     "Downstream consumers observe indeterminate latency characteristics during periodic "
     "reindexing intervals. Operators subsequently escalate anomalous throughput degradation "
     "toward the responsible engineering organization. Remediation presupposes familiarity with "
     "undocumented interdependencies among peripheral orchestration utilities. Comparable "
     "architectural inconsistencies permeate adjacent repositories. Institutional knowledge "
     "regarding provisioning irregularities remains predominantly undocumented.", "reading grade"),
    ("em dash", "The migration is complete — all 14 tables carry the index.", "em dash"),
    ("long sentence",
     "The hook reads the last assistant message from the session transcript and then it checks "
     "that message against every mechanical rule the humanize skill defines today.", "cap 25"),
]

NEGATIVE = [
    ("plain report",
     "Two hooks now enforce the rules, and `install.sh` registered both in `~/.claude/settings.json`."),
    ("mechanism prose",
     "It reads my last message from the session transcript and returns `decision: block` naming "
     "each violation. I then rewrite the message."),
    ("file and flag names",
     "The parser lives in src/parse.ts and has three entry points. The flag is --dry-run."),
    ("numbered steps",
     "1. Ran `install.sh`, then confirmed four links in `~/.claude/hooks/`.\n"
     "2. Fed a real payload to the hook and got valid JSON back."),
    ("bullets read on from a lead-in",
     "It blocks on:\n\n- sentences over 25 words\n- em dashes and double hyphens\n- emoji"),
    ("short verb sentences",
     "The hook fires. It reads the transcript. The check passes. I moved on."),
    ("technical nouns without a stack",
     "The Flesch-Kincaid grade level of the reply was 6.6 in the last run."),
    ("question",
     "Which files do you want me to change?"),
    ("comparison that is not a metaphor",
     "The new output matches the original, unlike the version I replaced."),
    ("lexicon gap",
     "The tokenizer normalizes the input before the resolver dereferences each alias."),
    ("code block untouched",
     "Here is the shape:\n\n```\nCertainly! Moreover, this is like a taxi rank.\n```\n\nThat block stays."),
    ("quoted line untouched",
     "The source says:\n\n> Certainly! Moreover, it is like a taxi rank.\n\nI left the quotation alone."),
    ("list heads the sentence",
     "Fragments, analogies, and dense prose now block the turn rather than warn."),
    ("lexical verb before the comma",
     "Bullets stay exempt, because a bullet reads on from its lead-in line."),
    ("short clause pair",
     "The hook fires twice, so the count is wrong."),
]


def main():
    failures = []
    for label, text, expected in POSITIVE:
        blocking, _ = pc.run_checks(text)
        if not any(expected in b for b in blocking):
            failures.append(f"MISS  {label}: expected a blocking finding containing {expected!r}")

    for label, text in NEGATIVE:
        blocking, _ = pc.run_checks(text)
        if blocking:
            failures.append(f"FALSE {label}: {blocking}")

    for line in failures:
        print(line)
    total = len(POSITIVE) + len(NEGATIVE)
    print(f"{total - len(failures)}/{total} fixtures pass")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
