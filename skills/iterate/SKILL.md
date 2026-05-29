---
name: iterate
description: >-
  Decompose a task into incremental parts, executing one at a time with user acceptance before proceeding.
  Use when the user says "let's iterate", "take this incrementally", "one piece at a time", "step by step",
  or otherwise indicates they want to work through a task incrementally rather than receiving the full output at once.
---

# Iterate

Execute the user's task incrementally through a structured call-and-response loop. Do not produce the full output at once. Instead, decompose, present, get acceptance, and proceed one piece at a time.

## When to Use

The user has described a goal (writing a prompt, building a config, drafting a document, designing an API, etc.) and wants to work through it piece by piece rather than receiving a complete artifact all at once.

## Process

### Phase 1: Understand and Decompose

1. Restate the goal in one sentence to confirm understanding.
2. Break the task into its smallest meaningful parts -- ordered sequentially where the output of each part feeds the next. Each part should be a coherent unit that can be reviewed independently.
3. Present the decomposition as a numbered outline. Each item gets a short title and a one-sentence description of what it covers.
4. Ask the user to confirm, reorder, add, or remove parts before proceeding.

Do NOT begin execution until the user accepts the outline.

### Phase 2: Incremental Execution

For each part in the accepted outline:

1. State which part you are on (e.g., "Part 2 of 6: Input Validation").
2. Produce ONLY that part's content. Do not preview or summarize later parts.
3. If this part depends on decisions or content from earlier accepted parts, reference them explicitly.
4. After presenting the part, ask the user one of:
   - "Accept this and move to the next part?"
   - "Want to revise anything before we continue?"
5. Wait for the user's response before proceeding.

User responses and how to handle them:

- **Acceptance** ("yes", "good", "next", "move on"): Incorporate the accepted part into the running artifact and proceed to the next part.
- **Revision request** ("change X to Y", "add Z", feedback): Apply the revision, re-present the updated part, and ask for acceptance again.
- **Rejection** ("no", "start over on this part", "try a different approach"): Produce a new version of the same part and present it for acceptance.
- **Skip** ("skip this", "not needed"): Mark it as skipped, note any downstream impacts, and move to the next part.
- **Reorder** ("do part 5 next instead"): Adjust the remaining order and proceed with the requested part.

### Phase 3: Assembly

After all parts are accepted:

1. Combine all accepted parts into the complete artifact.
2. Present the assembled result.
3. Ask if any final adjustments are needed across the whole.

## Rules

- Never produce more than one part at a time unless the user explicitly asks to batch multiple parts.
- Never skip the decomposition phase. Even if the task seems simple, present the outline first.
- Keep progress visible. Always state "Part N of M" so the user knows where they are.
- If the user's feedback on a part changes the scope or meaning of a later part, note this when you reach that part.
- If the user says "just do the rest" or "finish it", produce all remaining parts at once without further prompting.
- Do not editorialize about the approach or offer alternatives unless the user asks. This skill is about executing the user's intent incrementally, not questioning it.
