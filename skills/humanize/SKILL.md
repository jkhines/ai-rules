---
name: humanize
description: Audits writing for AI patterns ("AI-isms") and plain language failures, then reports, rewrites, or edits the file in place. Use when the user asks to humanize text, strip AI tells, judge whether something sounds machine-generated, simplify or clarify wording, cut jargon, check reading level, or make a document easier to read.
---
# Humanize

## When to use

Audit prose on two axes at once. First, remove AI writing patterns ("AI-isms") that make text sound machine-generated. Second, make it comprehensible, so a reader can find the information they need, understand what they find, and act on what they understand.

The two goals mostly agree. Both want short familiar words, active voice, and concrete claims. Where they disagree, plain language wins, and the conflicting rules below say so at the point of conflict.

Do not use this to change how writing sounds. Register, warmth, formality, and stance belong to the writer (see Preserve the writer's voice).

This is a writing-quality tool, not a verdict on authorship. Humans under deadline, in unfamiliar genres, or writing in a second language produce the same shapes, and commercial detectors misclassify their work at rates above 60%. Treat every flag as a writing problem worth fixing, never as proof a machine wrote it.

## Input

Audit whatever content the user supplies: a string in the request itself, a file path, or a URL. Fetch a URL before auditing it and name the URL you read. If the user supplies several inputs at once, audit them all and report on each separately.

Audit the text and change nothing unless the request asks for a change. "Rewrite," "clean this up," and "make it sound less like AI" ask for one. Naming a file on its own does not. An audit is also the right answer when the flagged patterns might be deliberate. It fits equally when the writer wants to decide for themselves what to fix.

Where a change goes follows from the input. Text supplied in the request comes back rewritten as text. A file the user asks you to fix is changed in place. A URL can never be.

Four more requirements apply when you change a file in place. Make minimal, targeted edits to the flagged spans rather than rewriting the whole document. Leave passages that are already human as they are. Confirm which section to clean first if the file is large. Re-read the file afterward and confirm the flagged patterns are resolved.

**Every rule applies at full strength to every input.** There is no genre setting and no way to relax a rule for a given kind of text.

**Fix, do not defer.** Whenever you change the text, a flag is not an output. Every flag you raise gets a replacement written into the text. This is the only override, and it has a high bar: you may keep a flagged word only when replacing it would make the sentence factually wrong, and you must name the fact that breaks. "It is a term of art," "it is the writer's terminology," "it appears in a heading," and "changing it is the author's call" are not that fact. If a word is confusing, ambiguous, or undefined for the reader, it fails the three tests and it gets replaced, whatever else it is doing.

When no table entry fits, do not force one. Name the thing literally in the words the reader already has.

## Meaning preservation (mandatory before you change any sentence)

Rewriting for cadence without re-parsing the sentence is how meaning drifts. Before changing a sentence:

1. Identify each verb with its subject and object.
2. List the discrete facts, user options/choices, numbers, dates, and named entities the sentence contains.
3. Rewrite or edit.
4. Diff the new sentence's list against the original's. If any verb, object, option, number, date, or named entity changed or dropped, revert and redo. A clause demoted to a parenthetical aside that was actually a coordinate action (for example "approve or reset their edits, and submit" — three actions sharing the object "edits") is a drift failure.
5. Read the rewrite cold, with the original hidden, to catch idiom and preposition failures that only surface when you hear the sentence as a reader would.

Show the diff at the level of facts and options preserved, so the writer can verify meaning without re-parsing the sentence themselves.

## Technical artifacts (never rewritten, always verified)

This skill changes prose and nothing else. A reader copies, runs, or matches these against a real system, so one altered character makes them wrong:

- commands and their flags
- file paths, directory names, and file names
- endpoints, HTTP verbs, and URLs
- environment variable names and their values
- default values, thresholds, and configuration settings
- version numbers, quantities, dates, scores, and percentages
- identifiers such as function, class, table, and field names

Markup is not what protects them. They keep their exact characters wherever they sit. That includes a fenced block, an inline code span, a table cell, and bare prose with no markup at all. A flagged word inside one of them stays. Replacing it makes the text factually wrong, which is the override Fix, do not defer already allows, so flag it and move on.

Two rules below legitimately change one of these. Spelling out an acronym on first use can alter a digit, as `E2E` becomes `end-to-end`. The rule on numbers and time periods rewrites `12 months` as `one year`. Nothing else may.

### Compare the artifacts before and after

Meaning preservation checks one sentence at a time, judged by the same reader who just changed it. This check is mechanical and covers the whole text, so it catches what per-sentence review misses. Run it every time you change anything, and report the result.

1. Capture the original before the first edit, with `git show HEAD:<path>` for a tracked file or a scratch copy for anything else.
2. Extract four sets from the original and from the changed version: every fenced code block, every inline code span, every URL, and every number.
3. Compare each set as a multiset, so a repeated value has to repeat the same number of times.
4. Name every difference in the report, along with the rule that caused it. The expected count is zero.
5. Restore the original wherever a difference has no rule behind it.

The check is order-insensitive and it only sees backticked code. So it passes a path moved between sentences, and it misses a path written without markup. Those two cases need your own reading.

## What to remove or fix

### Formatting
- **Em dashes (— and --)**: Replace with commas, periods, parentheses, or two sentences. Target: zero. Hard max: one per 1,000 words. Applies to headings too. Catch both the Unicode em dash and the double-hyphen substitute.
- **Bold overuse**: Strip bold from most phrases. One bolded phrase per major section at most. If something is important enough to bold, restructure the sentence to lead with it.
- **Emoji in headers**: Remove entirely. Exception: social posts may use one or two sparingly, at end of line, never mid-sentence.
- **Malformed bullet lists**: Bullets make text easier to read, so keep them. Every list needs a lead-in line, more than one bullet, and bullets that read on grammatically from the lead-in. Each bullet starts lowercase and runs no longer than one sentence; use commas or dashes to extend an item. No "and" or "or" after the second-to-last bullet, no semicolons, no period after the last bullet. Numbered steps are the exception: use them for a process, skip the lead-in line, and end each step with a period.
- **Curly quotation marks**: Replace with straight quotes in code and commit messages, where nothing auto-curls. Leave them everywhere else, and never flag a curly apostrophe alone.
- **Inline label-value notes**: Never use `Label: sentence` or `Label. sentence` in generated prose. Fold the label's meaning into a grammatical sentence or a connected paragraph. Preserve every fact carried by both parts, including the topic, named entities, ownership, status, decision, qualifier, and next action. For example, rewrite `Roadmap status: The transcript editor remains on track.` as `The roadmap remains on track, including the transcript editor.` Do not retain this construction even when the source uses it.

### Sentence structure
- **"It's not X — it's Y" / "This isn't about X, it's about Y" / "X is not Y, it's Z"** (negative parallelism): Rewrite as a direct positive statement, including the negated-clause-first and reversed ("Y, not X") variants. Meaning preservation outranks this rule. When the negated half carries a fact the positive statement would lose, keep the fact and restructure around it. Deleting the clause to satisfy this rule is a meaning-drift failure, not a fix.
- **Hollow intensifiers**: Cut `genuine`/`genuinely`, `real` ("a real improvement"), `truly`, `quite frankly`, `to be honest`, `let's be clear`. State the fact.
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
| thread (work-grouping metaphor) | flow |
| path / pathway (route/plan metaphor) | approach |
| gate / gating (checkpoint metaphor) | prerequisite, check |
| seam (joining metaphor) | integration point |
| tapestry | (describe the actual complexity) |
| realm | area, field, domain |
| paradigm | model, approach, framework |
| embark | start, begin |
| beacon | (rewrite entirely) |
| testament to | shows, proves, demonstrates |
| robust | strong, reliable, solid |
| comprehensive | thorough, complete, full |
| cutting-edge | latest, newest, advanced |
| lane | area |
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
- "Here's what's interesting" / "Here's what stood out" → let the content signal its own importance
- "In conclusion" / "In summary" / "To summarize" → your conclusion should be obvious
- "When it comes to" → talk about the thing directly
- "At the end of the day" → cut
- "That said" / "That being said" → cut or use "but," "yet," or "however"

### Structural issues
- **Formulaic openings**: If the piece opens with broad context before the point ("In the rapidly evolving world of..."), rewrite to lead with the news or insight. Context can come second.
- **Suspiciously clean grammar**: Leave the writer's existing irregularities alone. Deliberate fragments, sentences starting with "And" or "But," comma splices for effect: if the natural voice uses them, keep them. Do not add new ones. Keep an irregularity only where it stays unambiguous; a comma splice that makes the reader reparse the sentence fails the second of the three tests and gets fixed.

### Significance inflation
- "marking a pivotal moment in the evolution of..." or "a watershed moment for the industry" inflate routine events. State what happened and let the reader judge significance.
- If the sentence still works after you delete the inflation clause, delete it.

### Copula avoidance
- AI avoids "is" and "has" by substituting fancier verbs ("presents," "represents," and the Tier 1 entries for `serves as`, `features`, `boasts`). Default to "is" or "has" unless a more specific verb adds meaning.

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

### Bold labels on list items
- A bold header that repeats the item ("**Performance:** Performance improved by...") gets the header stripped and the point written directly. If items need headers, they should probably be paragraphs.
- A bold label ending in a period, with the explanation as a separate sentence (`**Intros.** Years of conferences...`), is a machine pattern; a person uses a colon (`**Intros:** years of conferences...`). Fix the period to a colon and lowercase the gloss, or drop the label. When the label is a full sentence on its own, the period is correct.

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
- Persuasive-authority tropes: "the real question is," "fundamentally," "make no mistake," "the truth is." Cut the trope and lead with the substance.

### Rhythm

**Clarity outranks rhythm. Always.** Similar sentence lengths are a weak sign of machine writing, and chasing that sign costs more than it is worth. Uniform length is not a defect if every sentence is clear. Never lengthen, merge, or complicate a sentence to create variety, and never keep a confusing sentence because it reads better. Add a short sentence or a fragment where it costs no clarity. Otherwise let the lengths be similar.

### Padding

Read each paragraph and ask what is new in it. If you could cut half and lose no information, the prose is restating itself. Name the one fact each paragraph adds; if there is none, cut the paragraph.

### When to rewrite from scratch vs. patch
If the text has 5+ flagged vocabulary hits across multiple categories and 3+ distinct pattern categories, patching won't fix it — the structure itself is AI-generated. Advise a full rewrite: state the core point in one sentence, then rebuild.

## Plain language

Everything above removes what should not be there. This section checks that what remains can be understood. Apply it on every audit, whatever the output.

Plain English is a set of principles for writing clearly and accurately, such as using short sentences. Plain language modifies those techniques to suit the needs of the reader and adapts to what user research shows. So treat this section as a floor, not a ceiling: if the writer has evidence that their readers say something else, the readers win.

### The three tests

Content passes when a reader can:

- find the information they need
- understand what they find
- act on what they understand

If a passage fails one of these, it fails the section, no matter how clean its vocabulary is.

### Write clearly for specialists too

Plain language is not a concession to non-experts. Research into specialist legal language found 80% of people preferred sentences written in clear English, and the preference grew as the issue got more complex, the reader got more educated, and their knowledge got more specialist. Experts can parse complex language. They do not want to when an alternative exists.

So this section applies to technical and specialist writing exactly as it applies to general writing. A knowledgeable audience is not a reason to relax it.

### Sentence and paragraph length

- Split any sentence over 25 words.
- Hold paragraphs to 5 sentences or fewer.
- There is no minimum or maximum page length. A single paragraph of jargon is too long.

The cap is a ceiling, not a target. Split a 40-word sentence; do not pad a 10-word one.

### Active voice

Prefer the active voice. It is more direct, it puts the focus on the reader and the action they need to take, and it keeps sentences short. The passive produces longer sentences and harder reading. "You need a permit" beats "A permit is needed."

Two cases where the passive is correct:

- the outcome matters more than whoever caused it, as in "the old system has been replaced"
- the passive is the more reader-centered choice, as in "you'll be told what to do when you apply" rather than naming an organization the reader does not care about

### Front-load

Put the most important information first, then taper to smaller details. The faster you reach the point, the more likely the reader sees it. Readers skim: they take in roughly 20% to 28% of the text on a page, scanning in an F shape across the top, down the side, and across again until they find what they need. Many are stressed or in a hurry.

### Headings

Write headings that are:

- descriptive, so avoid generic ones like "Introduction"
- front-loaded, with the most important word first
- active, starting with a verb where possible, so "Apply for a permit" rather than "You can apply for a permit"
- removable, meaning the content still makes sense with every heading deleted

Headings should not be questions, because questions are hard to front-load and readers want answers. They should not use technical terms you have not already explained.

### Jargon and specialist terms

Specialist terms are not automatically jargon. Use one when the reader needs it, then explain it in plain words the first time it appears on each page or screen. Write the term, then the gloss.

Prefer the words readers already use. Search terms are good evidence for which of two synonyms readers reach for.

Spell out an acronym in full the first time it appears on a page. If research shows readers know the acronym better than the expansion, lead with the acronym and put the expansion in parentheses. On a landing or start page, use the full name, then the acronym afterward.

### Words to avoid

Plain English rules out formal or long words where short familiar ones work: "buy" not "purchase", "help" not "assist", "about" not "approximately". Words ending in "-ion" and "-ment" make sentences longer and more complicated than they need to be; break the noun back into the verb it came from.

This table overlaps the Tier 1 and Tier 2 tables above on `utilize`, `leverage`, `in order to`, `robust`, `streamline`, `facilitate`, `foster`, `empower`, and `overarching`. The suggested replacements are worded differently in the two places but point the same direction, so use whichever fits the sentence. The difference that matters is the trigger: the tiers flag these words because AI overuses them, and this table flags them because readers stumble on them, so a word listed here is worth replacing even in text no one suspects of being machine-generated.

| Replace | With |
|---|---|
| agenda (unless a meeting agenda) | plan |
| advance (verb) | improve, or something more specific |
| collaborate | work with |
| combat (unless military) | solve, fix, or something more specific |
| commit / pledge | plan to, we're going to (with a specific verb) |
| counter (verb) | prevent, or rephrase as a solution to a problem |
| deliver (unless physical goods) | make, create, provide |
| deploy (unless military or software) | use, build, put into place |
| dialogue | discussion, spoke to |
| disincentivize | discourage, deter |
| drive (metaphor) | create, cause, encourage |
| drive out | stop, avoid, prevent |
| empower | allow, give permission |
| facilitate | say specifically how you are helping; "run" if it is a workshop |
| focus (verb) | work on, concentrate on |
| foster (unless children) | encourage, help |
| going forward / moving forward | from now on, in the future |
| hub / portal / one-stop shop | website, service |
| impact (unless a collision) | have an effect on, influence |
| in order to | to, or cut entirely |
| incentivize | encourage, motivate |
| initiate | start, begin |
| key (unless it unlocks something) | cut it, or use important, significant |
| land (verb, unless aircraft) | get, achieve |
| leverage (unless financial) | use, influence |
| liaise | work with, work alongside |
| overarching | cut it, or use encompassing |
| progress (verb) | work on, develop, make progress |
| promote (unless advertising or a career) | recommend, support |
| ring-fencing | separate, or name what the money will be spent on |
| robust (unless a sturdy object) | well thought out, thorough |
| slim down | make smaller, reduce the size |
| streamline | simplify, remove unnecessary administration |
| strengthening (unless a physical structure) | name the action: increase funding, add staff |
| tackle (unless physical) | stop, solve, deal with |
| transform | describe what you are changing and how |
| utilize | use |

Avoid metaphors generally. They do not say what you mean and they slow comprehension.

### Contractions

Use positive contractions like "you'll". Avoid negative contractions like "can't" and "don't", because many readers find them harder to read or misread them as the opposite of what they say; write "cannot" instead. Avoid complex and conditional contractions too: "should've", "could've", "would've".

### Requirement verbs

- **must** for a legal requirement.
- **legal requirement** or **legally entitled** where "must" does not carry enough weight.
- **need** for a requirement that is procedural rather than legal, where not doing it stops the reader progressing but carries no penalty.
- **can** for anything optional. Avoid "you may be able to".

### Address the reader

- Use "you" wherever possible.
- In the third person, stay gender neutral: "they can", not "he or she can".
- Name your organization in full before you start calling it "we". Do not assume the reader knows who "we" is.
- Drop "please" and "please note", including in instructions.
- Do not set large amounts of text in capitals. It is hard to read and it reads as shouting.
- Avoid job titles as identifiers. Describe what the role does: "the person who manages your recruitment should upload the job advertisement" beats naming a title that varies between organizations and changes when they reorganize.
- Do not write "you were unsuccessful". Move the failure off the person: "your application was unsuccessful on this occasion, but you can apply again."
- Name both halves of a role pair rather than the dominant one, so the reader who holds the other half sees themselves.

### Subjective adjectives

Adjectives carrying a judgment rather than a fact make text read as spin, and they are the one part of register that is a construction problem: they add words without adding information. Cut them, or replace each one with the fact that earned it. This is not a rule about how warm or formal the writing should be, which is the writer's call.

### Naming a product or service

Use the name inside a sentence rather than as a bare noun. If you must use it as a noun, put it at the start of the sentence so it does not read as a typo. Capitalize only the first letter, skip the quotation marks, and do not append the word "service" unless it is genuinely part of the name.

### Numbers and time periods

Write time periods of 12 months or more consistently, in years and months: "this course takes about one year to complete", "this program takes 2 years and 6 months to complete."

### Structure housekeeping

- No footnotes. They are a print convention. If the information matters, put it in the body; if it does not, cut it.
- Do not repeat the summary in the first paragraph.

## Severity tiers

When triaging, prioritize by tier:

**P0 — Credibility killers and comprehension failures (fix immediately):** cutoff disclaimers; chatbot artifacts; vague attributions without sources; significance inflation on routine events; chat markup leaks and unfilled placeholders; unexplained specialist terms or acronyms; any passage that fails one of the three tests.

**P1 — Obvious AI smell and plain language violations (fix before publishing):** Tier 1 word violations; words-to-avoid violations; template and slot-fill phrases; "let's" openers; synonym cycling; formulaic openings; bold overuse; em dash frequency; generic future-narrative closers; negative parallelism; sentences over 25 words; paragraphs over 5 sentences; passive voice outside its two exceptions; buried lead instead of front-loaded content; negative contractions.

**P2 — Stylistic polish (fix when time allows):** generic conclusions; compulsive rule of three; copula avoidance; transition phrases; Tier 3 density; malformed bullet lists; question headings and generic headings; footnotes; "please"; a summary repeated in the first paragraph.

Use P0+P1 for quick passes. Full audit covers all three tiers.

## Quoted and attributed text

Only the author's own prose is yours to change. Leave anything inside quotation marks, anything marked as illustrative ("for example, AI might write..."), and anything attributed to someone else. Flag the pattern and move on. Rewriting borrowed words puts claims in someone else's mouth. That makes the text factually wrong, which is the override Fix, do not defer already allows.

This matters most when writing *about* AI writing patterns, where the quoted examples are supposed to contain the patterns.

## Preserve the writer's voice

This skill changes how sentences are built, never how the writing sounds. Register, warmth, formality, humor, and stance belong to the writer. Fix the construction and hand back prose that still sounds like them.

Concretely: do not make casual writing more professional or formal writing more relaxed, do not add or remove first person, do not soften or sharpen a stated position, and do not swap the writer's habitual words for ones you consider better. This protects register, not vocabulary. A confusing word is a construction defect, and replacing it is not a change of voice. Defer only when a rule can be satisfied *only* by shifting formality, warmth, or stance.

## Output format

### Audit report (default, when nothing is changed)

**1. Issues found** — A bulleted list of every AI-ism and plain language failure identified, with the offending text quoted, grouped by severity (P0, P1, P2). Mark each one as an AI pattern, a comprehensibility problem, or both.

**2. Readability** — The longest sentence and its word count, and the longest paragraph and its sentence count. After a rewrite or edit, give both counts before and after.

**3. Assessment** — For each flag, note whether it's a clear problem or a judgment call. Some AI-associated patterns are effective in context. Call out which to definitely fix vs. which are worth a second look. If the text is clean, say so. Say separately whether the text passes the three tests: can a reader find what they need, understand it, and act on it.

### Rewritten text, returned in the reply

**1. Issues found** — Bulleted list of every AI-ism, with offending text quoted.

**2. Rewritten version** — The full rewritten content. Preserve the intent and all specific technical details (apply Meaning preservation above). Convert inline label-value notes into connected prose, retaining the information conveyed by each label.

**3. What changed** — Brief summary of the meaningful edits.

**4. Second-pass audit** — Re-read the rewritten version from section 2. Identify any remaining AI tells and plain language failures that survived the first pass, fix them, return the corrected text inline, and note what changed. Check the longest sentence and paragraph against the 25-word and 5-sentence limits, and confirm every specialist term and acronym is explained on first use. If the rewrite is clean, say so.

### Report after changing a file in place

Return a short report rather than the full file:

**1. Edits made** — Bulleted list of changes, each with the file location and before → after. Only the spans you touched.

**2. Verification** — Confirm you re-read the file and the flagged patterns are resolved. Report the longest surviving sentence and paragraph. Note anything you deliberately left alone because it was already human or intentional.

## Final checks

The goal is writing that reads as though a person built it and that a reader can act on. Direct. Specific. The writing should demonstrate confidence, not assert it.

1. **Be concrete** — replace vague claims with numbers, names, dates, or examples.
2. **Earn your emphasis** — don't tell the reader something is interesting. Make it interesting.

If the original writing is already strong, say so and make only the necessary cuts. The tables give defaults, not the only wording: pick a better replacement when one exists, but pick one. Keeping the flagged word is governed by Fix, do not defer.

## Attribution

Adapted from avoid-ai-writing (https://github.com/conorbronsdon/avoid-ai-writing), Copyright (c) 2026 Conor Bronsdon, MIT License. The pattern catalogue draws on Wikipedia's "Signs of AI writing" (WikiProject AI Cleanup) and the detection research cited above. Crypto/web3-specific phrase rules from the source were dropped as out of scope.

The Plain language section adapts the UK Department for Education Plain Language standard (DDTS-529) and the GOV.UK writing guidelines and A to Z style guide. That material is Crown copyright, used under the Open Government Licence v3.0 (https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/). British spelling, date, and currency conventions were converted to American ones, British institutional terms were dropped, and the source's examples were rewritten as domain-neutral.
