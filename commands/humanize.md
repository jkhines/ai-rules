---
command: /humanize
description: Audit writing for AI patterns ("AI-isms"); detect-only by default, with rewrite and edit modes
alwaysApply: false
---
Adapted from avoid-ai-writing (https://github.com/conorbronsdon/avoid-ai-writing), Copyright (c) 2026 Conor Bronsdon, MIT License. The pattern catalogue draws on Wikipedia's "Signs of AI writing" (WikiProject AI Cleanup) and the detection research cited below. Crypto/web3-specific phrase rules from the source were dropped as out of scope.

You are auditing content to find and optionally remove AI writing patterns ("AI-isms") that make text sound machine-generated.

## What this is and isn't

This is a writing-quality tool, not a verdict. The patterns flagged here are statistically more common in LLM output, but humans on autopilot — under deadline, in unfamiliar genres, or writing in a second language — produce the same shapes. Independent audits of commercial AI detectors found false-positive rates above 60% on non-native English writers (Liang et al., Stanford, *Patterns* 2023) and overall misclassification above 70% on open-source detectors (Jabarian & Imas, BFI Working Paper 2025-116, 2025). Adversarial paraphrase cuts detection accuracy by ~88% across every method tested (arXiv:2506.07001, 2025).

Treat the flags as signals worth acting on, never as proof. Pair them with context: who wrote it, what genre, what the writer's normal voice looks like.

## Modes

**`detect`** (default) — Flag AI-isms only. No rewriting. Use this to show what's flagged and let the writer decide what to fix, when flagged patterns might be intentional, or when auditing text you don't want altered. Default to this mode if none is specified.

**`rewrite`** — Flag AI-isms and return a clean rewritten version.

**`edit`** — Edit a file in place rather than returning rewritten text. Make minimal, targeted edits to the flagged spans, not the whole document. Preserve passages that are already human. Do not edit quoted material, code blocks, or text attributed to someone else; flag those instead. For a large file, confirm which section to clean before changing anything. After editing, re-read the file and confirm the flagged patterns are resolved.

Trigger rewrite when the user says "rewrite," "clean this up," "make it sound less like AI." Trigger edit when the user names a file and asks you to fix it in place. Otherwise stay in detect.

**Invocation.** Natural language is enough. Power users can pass explicit options: `[--mode detect|rewrite|edit]`, `[--voice casual|professional|technical|warm|blunt]`, `[--context blog|technical-blog|docs|linkedin|investor-email|casual]`, `[--file PATH]`, `[--iterate N]` (max 2).

**Iterate to convergence (optional).** Rewrite mode already runs one corrective second pass (see Output format); that built-in pass is pass 2, so `--iterate` does not stack on top of it. When asked to iterate, repeat the audit→rewrite cycle until no patterns remain or N passes are reached. Cap N at 2; a third pass costs a full regeneration while rarely finding more. Report how many passes it took.

## Meaning preservation (mandatory before any rewrite or edit)

Rewriting for cadence without re-parsing the sentence is how meaning drifts. Before changing a sentence:

1. Identify each verb with its subject and object.
2. List the discrete facts, user options/choices, numbers, dates, and named entities the sentence contains.
3. Rewrite or edit.
4. Diff the new sentence's list against the original's. If any verb, object, option, number, date, or named entity changed or dropped, revert and redo. A clause demoted to a parenthetical aside that was actually a coordinate action (for example "approve or reset their edits, and submit" — three actions sharing the object "edits") is a drift failure.
5. Read the rewrite cold, with the original hidden, to catch idiom and preposition failures that only surface when you hear the sentence as a reader would.

Show the diff at the level of facts and options preserved, so the writer can verify meaning without re-parsing the sentence themselves.

## What to remove or fix

### Formatting
- **Em dashes (— and --)**: Replace with commas, periods, parentheses, or two sentences. Target: zero. Hard max: one per 1,000 words. Applies to headings too. Catch both the Unicode em dash and the double-hyphen substitute.
- **Bold overuse**: Strip bold from most phrases. One bolded phrase per major section at most. If something is important enough to bold, restructure the sentence to lead with it.
- **Emoji in headers**: Remove entirely. Exception: social posts may use one or two sparingly, at end of line, never mid-sentence.
- **Excessive bullet lists**: Convert bullet-heavy sections into prose. Bullets only for genuinely list-like content (comparisons, steps, API parameters).
- **Curly quotation marks**: A weak paste-from-chat signal, meaningful mainly in plain-text contexts (code comments, commit messages) where nothing auto-curls. Word, Google Docs, macOS, and iOS curl quotes by default, so most human prose has them. Don't flag curly apostrophes alone. Replace with straight quotes in plain-text/code; leave them in finished publications.

### Sentence structure
- **"It's not X — it's Y" / "This isn't about X, it's about Y" / "X is not Y, it's Z"** (negative parallelism): Rewrite as a direct positive statement. Target: zero. Remove every instance, including the negated-clause-first and reversed ("Y, not X") variants. Never keep one, even when it appears to serve the argument.
- **Hollow intensifiers**: Cut `genuine`/`genuinely`, `real` ("a real improvement"), `truly`, `quite frankly`, `to be honest`, `let's be clear`, `it's worth noting that`. State the fact.
- **Vague endorsement ("worth [verb]ing")**: Cut or replace `worth reading`, `worth paying attention to`, `worth a look`, `worth exploring`. Say why it matters instead.
- **Hedging**: Cut `perhaps`, `could potentially`, `it's important to note that`, `to be clear`. Make the point directly.
- **Missing bridge sentences**: Each paragraph should connect to the last. If paragraphs could be rearranged without the reader noticing, add connective tissue.
- **Compulsive rule of three**: Vary groupings. Use two items, four, or a full sentence. Max one "adjective, adjective, and adjective" per piece.

### Words and phrases to replace

Words are organized into three tiers by how reliably they signal AI text. Match inflected forms (adverb, gerund, plural, conjugations) unless a variant has a distinct honest meaning.

- **Tier 1 — Always flag.** Appear 5–20x more often in AI text. Replace on sight.
- **Tier 2 — Flag in clusters.** Fine alone; two or more in one paragraph is a strong signal.
- **Tier 3 — Flag by density.** Common words AI overuses. Flag only when they make up a noticeable fraction (~3%+) of the text.

#### Tier 1 — Always replace

| Replace | With |
|---|---|
| delve / delve into | explore, dig into, look at |
| landscape (metaphor) | field, space, industry, world |
| stream / workstream (work-grouping metaphor) | area |
| path / pathway (route/plan metaphor) | approach |
| gate / gating (checkpoint metaphor) | prerequisite |
| tapestry | (describe the actual complexity) |
| realm | area, field, domain |
| paradigm | model, approach, framework |
| embark | start, begin |
| beacon | (rewrite entirely) |
| testament to | shows, proves, demonstrates |
| robust | strong, reliable, solid |
| comprehensive | thorough, complete, full |
| cutting-edge | latest, newest, advanced |
| leverage (verb) | use |
| pivotal | important, key, critical |
| underscores | highlights, shows |
| meticulous / meticulously | careful, detailed, precise |
| seamless / seamlessly | smooth, easy, without friction |
| game-changer / game-changing | describe what specifically changed and why it matters |
| utilize | use |
| watershed moment | turning point, shift |
| nestled | is located, sits, is in |
| vibrant | (describe what makes it active, or cut) |
| thriving | growing, active (or cite a number) |
| showcasing | showing, demonstrating (or cut the clause) |
| deep dive / dive into | look at, examine, explore |
| unpack / unpacking | explain, break down, walk through |
| intricate / intricacies | complex, detailed (or name the specific complexity) |
| ever-evolving | changing, growing (or describe how) |
| daunting | hard, difficult, challenging |
| holistic / holistically | complete, full, whole |
| actionable | practical, useful, concrete |
| impactful | effective, significant (or describe the impact) |
| learnings | lessons, findings, takeaways |
| best practices | what works, proven methods, standard approach |
| at its core | (cut — just state the thing) |
| synergy / synergies | (describe the actual combined effect) |
| in order to | to |
| due to the fact that | because |
| serves as | is |
| features (verb) | has, includes |
| boasts | has |
| commence | start, begin |
| ascertain | find out, determine, learn |
| endeavor | effort, attempt, try |
| embrace (metaphor) | adopt, accept, use, switch to |

#### Tier 2 — Flag when 2+ appear in the same paragraph

| Replace | With |
|---|---|
| harness | use, take advantage of |
| navigate / navigating | work through, handle, deal with |
| foster | encourage, support, build |
| elevate | improve, raise, strengthen |
| unleash | release, enable, unlock |
| streamline | simplify, speed up |
| empower | enable, let, allow |
| bolster | support, strengthen, back up |
| spearhead | lead, drive, run |
| resonate / resonates with | connect with, appeal to, matter to |
| revolutionize | change, transform, reshape |
| facilitate / facilitates | enable, help, allow, run |
| underpin | support, form the basis of |
| nuanced | specific, subtle, detailed (or name the actual nuance) |
| crucial | important, key, necessary |
| multifaceted | (describe the actual facets, or cut) |
| ecosystem (metaphor) | system, community, network, market |
| myriad | many, numerous (or give a number) |
| plethora | many, a lot of (or give a number) |
| encompass | include, cover, span |
| catalyze | start, trigger, accelerate |
| augment | add to, expand, supplement |
| cultivate | build, develop, grow |
| illuminate | clarify, explain, show |
| elucidate | explain, clarify, spell out |
| transformative / transformation | (describe what changed and how) |
| cornerstone | foundation, basis, key part |
| paramount | most important, top priority |
| poised (to) | ready, set, about to |
| burgeoning | growing, emerging (or cite a number) |
| nascent | new, early-stage, emerging |
| overarching | main, central, broad |

#### Tier 3 — Flag only at high density

| Word | What to do |
|---|---|
| significant / significantly | Replace some with specifics: numbers, comparisons, examples |
| innovative / innovation | Describe what's actually new |
| effective / effectively | Say how or cite a metric |
| dynamic / dynamics | Name the actual forces or changes |
| scalable / scalability | Describe what scales and to what |
| compelling | Say why it compels |
| unprecedented | Name the precedent it breaks (or cut) |
| exceptional / exceptionally | Cite what makes it an exception |
| remarkable / remarkably | Say what's worth remarking on |
| sophisticated | Describe the sophistication |
| instrumental | Say what role it played |
| world-class / state-of-the-art / best-in-class | Cite a benchmark or comparison |

### Template phrases (avoid)
- "a [adjective] step towards [X]" → describe the specific capability, benchmark, or outcome
- "Whether you're [X] or [Y]" → false-breadth construction. Pick the audience you're actually addressing, or cut.
- "I recently had the pleasure of [verb]-ing" → just say what happened: "I talked to," "I read," "I attended."

### Transition phrases to remove or rewrite
- "Moreover" / "Furthermore" / "Additionally" → restructure so the connection is obvious, or use "and," "also," "on top of that"
- "In today's [X]" / "In an era where" → cut or state specific context
- "It's worth noting that" / "Notably" → just state the fact
- "Here's what's interesting" / "Here's what stood out" → let the content signal its own importance
- "In conclusion" / "In summary" / "To summarize" → your conclusion should be obvious
- "When it comes to" → talk about the thing directly
- "At the end of the day" → cut
- "That said" / "That being said" → cut or use "but," "yet," or "however"

### Structural issues
- **Uniform paragraph length**: Vary deliberately. Include some 1-2 sentence paragraphs and some longer ones.
- **Formulaic openings**: If the piece opens with broad context before the point ("In the rapidly evolving world of..."), rewrite to lead with the news or insight. Context can come second.
- **Suspiciously clean grammar**: Don't sand away all personality. Deliberate fragments, sentences starting with "And" or "But," comma splices for effect: if the natural voice uses them, keep them.

### Significance inflation
- "marking a pivotal moment in the evolution of..." or "a watershed moment for the industry" inflate routine events. State what happened and let the reader judge significance.
- If the sentence still works after you delete the inflation clause, delete it.

### Copula avoidance
- AI avoids "is" and "has" by substituting fancier verbs: "serves as," "features," "boasts," "presents," "represents." Default to "is" or "has" unless a more specific verb genuinely adds meaning.

### Synonym cycling
- AI rotates synonyms to avoid repeating a word: "developers… engineers… practitioners… builders" in one paragraph. Human writers repeat the clearest word. If the same word appears three times and it's the right word, keep all three.

### Vague attributions
- "Experts believe," "Studies show," "Research suggests" without naming the expert, study, or source. Cite specifically or drop the attribution and state the claim directly.

### Filler phrases
- "It is important to note that" → state it. "In terms of" → rewrite. "The reality is that" → cut or state the claim.

### Generic conclusions
- "The future looks bright," "Only time will tell," "As we move forward" — filler disguised as conclusions. Cut them, or make the closing thought specific to the argument.

### Chatbot artifacts
- "I hope this helps!", "Certainly!", "Great question!", "Feel free to reach out," "Let me know if you need anything else" — conversational tics, not writing. Remove entirely.
- "In this article, we will explore…" / "Let's dive in!" — meta-narration. Cut or open directly.

### "Let's" constructions
- "Let's explore," "Let's take a look," "Let's break this down" — false-collaborative openers that delay the point. Start with the point. Flag any "let's + verb" functioning as a transition rather than a genuine invitation.

### Superficial -ing analyses
- Strings of present participles as pseudo-analysis: "symbolizing the region's commitment to progress, reflecting decades of investment, and showcasing a new era." These say nothing. Replace with specific facts or cut.
- The same move without -ing: "this represents a broader shift," "the decision symbolizes a commitment to excellence." If the significance is real, show it with a specific consequence; otherwise cut.

### Promotional language
- Tourism-brochure prose: "nestled within the breathtaking foothills," "a vibrant hub of innovation." Replace with plain description. If you wouldn't say it in conversation, cut it.

### Formulaic challenges
- "Despite challenges, [subject] continues to thrive" / "While facing headwinds, the organization remains resilient." A non-statement. Name the actual challenge and response, or cut.

### False ranges
- Pairing unrelated extremes: "from the Big Bang to dark matter," "from ancient civilizations to modern startups." Sweeping but empty. List the actual topics or pick the one that matters.

### Inline-header lists
- Bullets where each item starts with a bold header repeating itself: "**Performance:** Performance improved by..." Strip the bold header and write the point directly. If items need headers, they should probably be paragraphs.

### List-label periods
- LLMs end a short bold label with a period then run the explanation as a separate sentence (`**Intros.** Years of conferences...`); a person uses a colon (`**Intros:** years of conferences...`). Fix the period to a colon and lowercase the gloss, or drop the label. Carve-out: when the label span is a full sentence on its own, the period is correct.

### Title case headings
- AI over-capitalizes: "Strategic Negotiations And Key Partnerships" instead of "Strategic negotiations and key partnerships." Use sentence case for subheadings; title case only for the main title, if at all.

### Hyphenated-pair overuse
- AI stacks compound modifiers: "a high-quality, well-architected, future-proof solution." Cut to the modifier that matters. Also fix the attributive/predicate error: hyphenate before the noun ("a high-quality report") but not after a linking verb ("the report is high quality").

### Cutoff disclaimers and speculative gap-filling
- "As of my last update," "I don't have access to real-time data" — model limitations leaking into prose. Find the information or remove the hedge.
- Hedged speculation dressed as background ("is believed to have," "likely began his career in," "appears to have studied") hides a gap behind plausible filler. Cut it or replace with a sourced fact.

### Unfilled placeholders and chat markup leaks
- `[Your Name]`, `[INSERT SOURCE URL]`, `2025-XX-XX` — treat any visible placeholder as a publishing bug: fill it or delete the sentence.
- Citation/markup tokens (`citeturn0search0`, `oai_citation`, `[attached_file:1]`) and AI-tool URL parameters (`utm_source=chatgpt.com`, `utm_source=claude.ai`) are fingerprints. Strip them mechanically, regardless of how the surrounding text reads.

### Engagement hooks and rhetorical openers
- Infomercial fragment-hooks: "The catch?", "Here's the thing.", "Plot twist:". Delete the hook and state the thing.
- Rhetorical question openers: "But what does this mean for developers?" / "So why should you care?" If you know the answer, say it.

### Emotional flatline and self-labeling significance
- Claiming emotion as a crutch: "What surprised me most," "I was fascinated to discover," "What struck me was." If it's genuinely surprising, the reader should feel it from the content. Otherwise cut the claim.
- Back-pointing labels: "That last move is the contrarian one," "This is the interesting part." The label does the work the content should. Cut it and let the explanation carry the weight, or restructure so the highlighted item leads.

### Confidence calibration phrases
- "It's worth noting that," "Interestingly," "Surprisingly," "Importantly," "Notably," "Certainly," "Undoubtedly" — these tell the reader how to feel instead of letting the fact speak. One "notably" in 2,000 words is fine; three in 500 is emphasis stacking. Flag by density.
- Persuasive-authority tropes: "the real question is," "at its core," "fundamentally," "make no mistake," "the truth is." Cut the trope and lead with the substance.

### Rhythm and uniformity

Structure is the strongest detection signal — AI text is metronomic; human text has varied rhythm. Fixing every flagged word but leaving the rhythm untouched still reads as AI.

- **Sentence length uniformity**: If most sentences are 15–25 words, mix in short punchy ones (3–8 words) and longer flowing ones (20+). Fragments work.
- **Paragraph length uniformity**: Vary deliberately. Some paragraphs should be one sentence.
- **Read-aloud test**: If the text could be read by a text-to-speech engine without sounding weird, it's too uniform.
- **Over-polishing**: Aggressively editing out every irregularity pushes human writing *toward* AI statistical profiles. Don't sand away all personality. If you apply every rule at maximum strictness, you risk creating the very uniformity you're trying to avoid.

### Paragraph-reshuffle and treadmill tests (writer-side diagnostics)
- Can you swap two body paragraphs without breaking the piece? If order doesn't matter, you've written a list, not an argument that builds. Establish a through-line where each paragraph depends on the one before it.
- Read each paragraph and ask "what's actually new here?" If you could cut 40-60% and lose no information, the prose is restating the premise in fresh words instead of advancing it. Name the one fact or turn each paragraph contributes; if there isn't one, cut it.

### When to rewrite from scratch vs. patch
If the text has 5+ flagged vocabulary hits across multiple categories, 3+ distinct pattern categories, and uniform sentence/paragraph length, patching won't fix it — the structure itself is AI-generated. Advise a full rewrite: state the core point in one sentence, then rebuild.

## Severity tiers

When triaging, prioritize by tier:

**P0 — Credibility killers (fix immediately):** cutoff disclaimers; chatbot artifacts; vague attributions without sources; significance inflation on routine events; chat markup leaks and unfilled placeholders.

**P1 — Obvious AI smell (fix before publishing):** Tier 1 word violations; template and slot-fill phrases; "let's" openers; synonym cycling; formulaic openings; bold overuse; em dash frequency; generic future-narrative closers; negative parallelism.

**P2 — Stylistic polish (fix when time allows):** generic conclusions; compulsive rule of three; uniform paragraph length; copula avoidance; transition phrases; Tier 3 density.

Use P0+P1 for quick passes. Full audit covers all three tiers.

## Self-reference escape hatch

When writing *about* AI writing patterns, quoted examples are exempt. Text inside quotation marks, code blocks, or marked as illustrative ("for example, AI might write...") should not be rewritten. Only flag patterns in the author's own prose.

## Context profiles

Pass an optional context hint to adjust strictness. If none is given, auto-detect: short + hashtags = `linkedin`; code blocks or APIs = `technical-blog`; salutation + fundraising language = `investor-email`; step-by-step or README structure = `docs`; otherwise `blog` (all rules at full strength). If auto-detection feels wrong, say which profile you're using and why.

- **`linkedin`** — Short-form social. Relax em dashes (2/post), bold hooks, and short-form transitions; skip uniform-paragraph and bullet rules.
- **`blog`** — Default. All rules at full strength.
- **`technical-blog`** — Relax hedging ("may" is accurate), bullet/option lists, and these word-table terms with legitimate technical meaning: `robust`, `comprehensive`, `seamless`, `ecosystem`, `leverage` (platform/API sense), `facilitate`, `underpin`, `streamline`. Still flag `delve`, `tapestry`, `beacon`, `embark`, `testament to`, `game-changer`, `harness`.
- **`investor-email`** — Tighten everything; promotional language and significance inflation are the biggest risks (extra strict).
- **`docs`** — Clarity over voice. Relax em dashes, bold, hedging; skip emoji/copula rules.
- **`casual`** — Slack, internal notes. Catch only the worst offenders (P0).

## Voice profiles

Context profiles set how strict to be; voice profiles set how the prose should sound. Independent axes. Voice is optional — if the writer doesn't name one, infer it from the input's existing register and don't impose a persona on text that already has one.

- **`casual`** — Contractions throughout; short sentences (≤14 words avg); fragments allowed; at least one first-person or concrete touch; near-zero jargon; keep warm hedges ("honestly," "I think"), cut corporate ones.
- **`professional`** — Active voice; vary sentence length; one concrete claim per paragraph (number, name, date); explicit ask; low hedging.
- **`technical`** — Plain copulatives ("X is Y") over inflated substitutes; one idea per sentence; imperative for instructions; define jargon on first use; tables/lists only where content is genuinely list-shaped.
- **`warm`** — Address the reader ("you"); cut intensifiers in favor of stronger verbs; no performative-empathy openers; medium sentences (15–20 words).
- **`blunt`** — Lead with the claim; cut windups; rare em dashes (periods for emphasis); no padding to hit a rule of three; near-zero hedging; short declaratives with the occasional long sentence for contrast.

**Calibrate to a sample (optional).** If the writer gives a sample of their own writing, match its sentence-length pattern, contraction rate, paragraph openings, and word choices instead of a named profile. Don't upgrade their vocabulary.

Where voice and context govern the same rule and disagree, resolve toward the stricter of the two.

## Output format

### Detect mode (default)

**1. Issues found** — A bulleted list of every AI-ism identified, with the offending text quoted, grouped by severity (P0, P1, P2).

**2. Assessment** — For each flag, note whether it's a clear problem or a judgment call. Some AI-associated patterns are effective in context. Call out which to definitely fix vs. which are worth a second look. If the text is clean, say so.

### Rewrite mode

**1. Issues found** — Bulleted list of every AI-ism, with offending text quoted.

**2. Rewritten version** — The full rewritten content. Preserve the original structure, intent, and all specific technical details (apply Meaning preservation above). Only change what the guidelines require.

**3. What changed** — Brief summary of the meaningful edits.

**4. Second-pass audit** — Re-read the rewritten version from section 2. Identify any remaining AI tells that survived the first pass, fix them, return the corrected text inline, and note what changed. If the rewrite is clean, say so.

### Edit mode

After editing the file in place, return a short report — not the full file:

**1. Edits made** — Bulleted list of changes, each with the file location and before → after. Only the spans you touched.

**2. Verification** — Confirm you re-read the file and the flagged patterns are resolved. Note anything you deliberately left alone because it was already human or intentional.

## Tone calibration

The goal is writing that sounds like a person wrote it. Direct. Specific. The writing should demonstrate confidence, not assert it.

1. **Vary sentence length** — mix short with long. Fragments are fine.
2. **Be concrete** — replace vague claims with numbers, names, dates, or examples.
3. **Have a voice** — where appropriate, use first person, state preferences, show reactions.
4. **Cut the neutrality** — if the piece is supposed to take a position, take it.
5. **Earn your emphasis** — don't tell the reader something is interesting. Make it interesting.

If the original writing is already strong, say so and make only the necessary cuts. The replacement table provides defaults, not mandates: if a flagged word is clearly the right choice in context, preserve it.
