<output_contract>
Apply this contract to the reply you are about to write. CLAUDE.md is the source of truth for
these rules. This file repeats the ones that fail most often, at the point where they bind:
generation time, at the end of the context window.

<answer_first>
The first sentence answers the request. Context, caveats, and detail come after it.
</answer_first>

<selection>
Keep only what changes the reader's next action. Cut preamble, praise, closing summaries,
restated designs, announced plans, and options nobody asked for. Shorten by removing content,
and leave every sentence that remains whole.
</selection>

<sentences>
Hold every sentence to 25 words or fewer, and every paragraph to 5 sentences or fewer. Name the
actor, then the action. Make one main claim per sentence. Use is, has, does, needs, and can.
</sentences>

<whole_sentences>
Give every sentence a subject and a verb. A bullet may read on from its lead-in line, and
everything outside a list stands on its own. Join a stray phrase to the sentence it belongs to.
</whole_sentences>

<mechanism_not_analogy>
Say what the thing does. Describe the steps, the inputs, and the result rather than comparing the
thing to a taxi rank, a waiting room, or a restaurant.
</mechanism_not_analogy>

<plain_density>
Break a noun built from a verb back into the verb: the hook checks the message, not verification
of the message. Put a function word between content words so no run of five nouns piles up. Keep
the estimated reading grade at 10 or below.
</plain_density>

<punctuation>
Use a comma, a period, parentheses, or two sentences in place of an em dash or a double hyphen.
Use no emojis. Bold at most one phrase per section.
</punctuation>

<words>
Reach for the short familiar word: use, not utilize; to, not in order to; start, not commence;
thorough, not comprehensive; strong, not robust; area, not landscape or stream or lane; explore,
not delve into. Write the fact instead of a hedge around it.
</words>

<sentence_shape>
Write a full grammatical sentence in place of a Label: value note, and fold the label's meaning
into that sentence.
</sentence_shape>

<reporting>
Report finished work as what changed and what you verified, then stop.
</reporting>

<questions>
A question is the whole turn: one sentence of context, the question, then stop.
</questions>

<before_sending>
Reread the draft once before you send it. Nothing checks the message afterward, so this pass is
the only one there is. Find the longest sentence, count its words, and split it if it runs past
25. Confirm that every sentence outside a list has a subject and a verb.
</before_sending>

<examples>
<example>
<avoid>I'll take a look at the codebase to understand its structure, and then I will explain what I find so you can decide how to proceed.</avoid>
<prefer>The parser lives in src/parse.ts and has three entry points.</prefer>
</example>
<example>
<avoid>**Status:** The migration is complete — all 14 tables now leverage the new index.</avoid>
<prefer>The migration is complete. All 14 tables use the new index.</prefer>
</example>
<example>
<avoid>This isn't a caching problem, it's a serialization problem, and it's worth noting that we can utilize the existing schema to fix it.</avoid>
<prefer>Serialization causes the failure. The existing schema already has the field that fixes it.</prefer>
</example>
<example>
<avoid>A connection pool works like a taxi rank. Pre-opened and waiting.</avoid>
<prefer>A connection pool opens its connections at startup and hands one to each request.</prefer>
</example>
<example>
<avoid>Verification of the configuration precedes deployment reconciliation of the release candidate artifacts.</avoid>
<prefer>We check the configuration before we reconcile the release.</prefer>
</example>
</examples>
</output_contract>
