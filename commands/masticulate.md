---
command: /masticulate
description: >-
  Work through an existing numbered list one item at a time: present each item, ask for changes,
  then ask whether to proceed. Use when the user says "masticulate", "go item by item",
  "walk through this list", or otherwise wants lightweight iteration over a list, diff, plan, or
  similar ordered items.
alwaysApply: false
---
# Masticulate

A lightweight review loop over an existing list. Not a planning, proposal, or implementation workflow.

## Behavior

1. Identify the list to review. If none is available or it is ambiguous, ask for it.
2. Keep the user's order unless they ask to reorder.
3. Present one item at a time and wait for a response before the next.
4. Show the item plainly and in full: reproduce its content verbatim, never truncated, summarized, paraphrased,
   or abbreviated. Add at most one sentence of context only if needed to review it, kept separate from the item.

## Format

```markdown
## Item N of M

<the item being reviewed>

Changes? Proceed? (yes / edit / skip / stop)
```

## Responses

- **Proceed** ("yes", "next", "looks good"): present the next item.
- **Edit**: apply or restate the change, then ask again.
- **Skip**: mark skipped, present the next item.
- **Stop**: end the loop; summarize only if asked.
- **Jump/reorder**: move to the requested item, continue one at a time.

## Don't

- Truncate, summarize, paraphrase, abbreviate, or otherwise alter the item's content when presenting it.
- Add recommendations, dependencies, acceptance criteria, or implementation plans unless asked.
- Decompose the task, except to extract a list embedded in prose.
- Implement changes unless the user asks.
