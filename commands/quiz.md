---
command: /quiz
description: Build a mnemonic recall scaffold and quiz the user one question at a time
alwaysApply: false
---
# Quiz

Turn a topic into a recall-first learning loop. Use when the user asks to memorize, internalize, drill, study,
learn, recall, quiz, or build a mnemonic for any topic.

## Goal

Help the user recall the material from memory later. Do not optimize for a complete explanation. Optimize for
retrieval.

## Inputs

If the topic or source material is missing, ask for it in one sentence.

If the topic is available but source material is not, use the conversation context. If factual accuracy matters and the
content is external, retrieve the source before building the quiz.

## Method

1. Extract the smallest useful structure:
   - 3-5 top-level buckets.
   - 3-6 sub-buckets per top-level bucket.
   - One short meaning for each item.

2. Create a mnemonic:
   - Prefer a real word.
   - If no real word fits, use a pronounceable pseudo-word.
   - If neither works, use a short phrase.
   - Do not force a clever mnemonic that distorts the material.

3. Present only the first recall layer:
   - No wall of text.
   - No full outline unless the user asks for it.
   - Start with the top-level mnemonic and one-line meanings.

4. Quiz one prompt at a time:
   - Ask one short question.
   - Wait for the user's answer.
   - Correct briefly.
   - Only then add the next layer.

5. Use retrieval before review:
   - Ask the user to recall first.
   - Show the answer only after they try, ask, or get stuck.
   - Keep corrections short enough to preserve momentum.

6. Keep layers separate:
   - Top map first.
   - Sub-map second.
   - Priority/order third.
   - Boundary / not-in-scope items last.

## Output Pattern

Start like this:

```markdown
Round 1.

Mnemonic: **[WORD]**

1. **A** = [short meaning]
2. **B** = [short meaning]
3. **C** = [short meaning]

Your turn. What does **[WORD]** stand for?
```

For corrections:

```markdown
Correct.

Next layer:

1. ...

Quiz: [one short question]
```

If the user is wrong:

```markdown
Close. Fix:

2. **B** = [correct item]

Try again: [same short question]
```

If the user says they do not know:

```markdown
Use this chant:

[short chant]

Quiz: reply with only the first [N] words.
```

## Rules

- One question per response.
- Use numbered lists for answers the user should give back.
- Prefer 6 or fewer items per recall set.
- Keep explanations under 5 lines unless the user asks for more.
- Do not praise, encourage, or summarize.
- Do not introduce a new layer until the current layer is recalled correctly or the user skips it.
- If two buckets overlap, pause and define the boundary before continuing.
- If the mnemonic is clumsy, replace it immediately.

## Repeat-Quiz Prompt Template

When asked to create a reusable prompt, use:

```text
Act as an executive-function coach. Quiz me on [topic] using retrieval practice.
Do not explain first. Ask one short question at a time, wait for my answer, correct me briefly, then ask the next
question.

Start with the top-level mnemonic:
1. What does [MNEMONIC] stand for?
2. What does each item mean?

Then quiz each sub-map:
3. What does [SUB-MNEMONIC] stand for?
4. Give one example under each section.

Then quiz priority and boundaries:
5. What comes first?
6. What is out of scope or parallel?
```
