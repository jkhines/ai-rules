---
name: masticulate
description: Walk through an existing list, diff, or plan one item at a time: show each item verbatim, ask for edits, and wait to proceed. Use when asked to "masticulate" or go "item by item".
---
# Masticulate

A lightweight review loop over an existing list. Extract a list embedded in prose when needed, and make no recommendations, plans, or code changes unless the user asks.

## Behavior

1. Identify the list to review. If none is available or it is ambiguous, ask for it.
2. Keep the user's order unless they ask to reorder.
3. Present one item at a time and wait for a response before the next.
4. Show the item plainly and in full: reproduce its content verbatim, never truncated, summarized, paraphrased, or abbreviated. Add at most one sentence of context only if needed to review it, kept separate from the item.

## Format

```markdown
## Item N of M

<the item being reviewed>

Changes? Proceed? (yes / edit / skip / stop)
```

## Responses

- Proceed ("yes", "next", "looks good"): present the next item.
- Edit: apply or restate the change, then ask again.
- Skip: mark skipped, present the next item.
- Stop: end the loop and summarize only if asked.
- Jump or reorder: move to the requested item and continue one at a time.
