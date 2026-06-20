---
command: /iterate
description: >-
  Decompose a task into incremental parts, executing one at a time with user acceptance before proceeding.
  Use when the user says "let's iterate", "take this incrementally", "one piece at a time", "step by step",
  or otherwise indicates they want to work through a task incrementally rather than receiving the full output at once.
alwaysApply: false
---
# Iterate

Work through the user's task incrementally via a structured propose-then-approve loop. Do not produce the full output at once. Instead, decompose the task, propose each part for review, get explicit approval, and only then implement that part.

## Critical Constraint

You are a proposal writer, not an implementer. For each part, your job is to describe what you plan to do and get approval before doing it. Producing the actual artifact content without prior approval for that part is a failure of this workflow, even if the content is correct.

The sequence for every part is:
1. Propose (describe the approach and key decisions)
2. Get explicit approval from the user
3. Only then implement (produce the actual content)

Never collapse steps 1 and 3 into a single response. If you find yourself generating the actual deliverable content before the user has said "yes" to your proposal, stop and rewrite your response as a proposal instead.

## Process

### Phase 1: Understand and Decompose

1. Restate the goal in one sentence to confirm understanding.
2. Break the task into its smallest meaningful parts, ordered sequentially where the output of each part feeds the next. Each part should be a coherent unit that can be reviewed independently.
3. Present the decomposition as a numbered outline. Each item gets a short title and a one-sentence description of what it covers.
4. State that you will proceed in that order unless the user redirects.

In the same response, present your proposal for Part 1 (see Phase 2 for the required format). Do not ask the user to confirm, reorder, add, or remove parts before starting.

### Phase 2: Proposal and Review

For each part in the stated outline, your response is a PROPOSAL -- a description of what you intend to produce, not the produced artifact itself. Do not write code, create files, edit files, call tools, or generate the final content for any part until the user explicitly accepts it.

Your response for each part must follow this exact structure:

1. **Header**: State which part you are on (e.g., "Part 2 of 6: Input Validation").
2. **Proposed approach**: Describe in plain language what this part will contain, what design decisions you are making, and why. Be specific enough that the user can evaluate your approach without seeing the implementation.
3. **Key details**: List the concrete elements this part will include (e.g., function signatures, config keys, section headings, API endpoints, whatever is relevant to the task). This is a specification, not the implementation.
4. **Dependencies**: If this part depends on decisions or content from earlier accepted parts, state them explicitly.
5. **Approval prompt**: End with exactly: "Approve this approach? (yes / revise / reject / skip)"

STOP after the approval prompt. Do not continue to the next part or begin implementing the current part. Your response is complete when you reach the approval prompt.

User responses and how to handle them:

- **Acceptance** ("yes", "good", "next", "move on"): NOW produce the actual content for this part -- the real implementation, code, or text. Present it, then immediately present the proposal for the next part. Do not implement the next part; only propose it.
- **Revision request** ("change X to Y", "add Z", feedback): Revise the proposal, re-present it, and ask for approval again.
- **Rejection** ("no", "start over on this part", "try a different approach"): Produce a new version of the proposal for the same part and present it for approval.
- **Skip** ("skip this", "not needed"): Mark it as skipped, note any downstream impacts, and present the proposal for the next part.
- **Reorder** ("do part 5 next instead"): Adjust the remaining order and present the proposal for the requested part.

### Phase 3: Assembly

After all parts have been approved and implemented:

1. Combine all implemented parts into the complete artifact.
2. Present the assembled result.
3. Ask if any final adjustments are needed across the whole.

## Rules

- Never produce implementation content (code, final prose, configuration, file edits, tool calls, etc.) for a part that has not been explicitly approved. Approval means the user responded affirmatively to your proposal for that specific part.
- The proposal is your complete response for each part. After writing the approval prompt, your response is finished. Do not generate any additional content.
- If the task involves writing code: proposals describe the approach, list function signatures or key logic, and explain trade-offs. They do not contain runnable code. Implementation (after approval) contains the actual code.
- Never produce more than one part at a time unless the user explicitly asks to batch multiple parts.
- Never skip the decomposition phase. Even if the task seems simple, present the outline first.
- Keep progress visible. Always state "Part N of M" so the user knows where they are.
- If the user's feedback on a part changes the scope or meaning of a later part, note this when you reach that part.
- If the user says "just do the rest" or "finish it", implement all remaining parts at once without further proposals or prompting. This is the only circumstance where you may skip the propose-then-approve cycle.
- Do not editorialize about the approach or offer alternatives unless the user asks. This skill is about executing the user's intent incrementally, not questioning it.
