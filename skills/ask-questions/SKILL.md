---
name: ask-questions
description: Critique a problem and the proposed approach as a senior technical lead, then rank alternative approaches.
disable-model-invocation: true
---
# Ask questions

Run this workflow only when the user invokes `ask-questions` by name. Review the user's problem and proposed approach as a senior technical lead, then stop and wait for the user's decision.

## Analysis steps

1. Diagnose the problem:
   - Separate the underlying problem from the stated mechanism (XY problem check).
   - Classify the problem archetype (such as optimization, constraint satisfaction, architectural mismatch, race condition, or state management).
   - Extract the actual constraints and requirements without implementation assumptions.
2. Critique the proposed approach:
   - Check whether the proposal solves root causes or symptoms.
   - Surface hidden assumptions and cognitive biases (sunk cost, anchoring, confirmation bias, premature optimization).
   - Test each stated constraint to identify which constraints are fixed and which can be removed.
3. Rank alternatives:
   - Identify 2 to 3 distinct strategies (such as changing the data structure, push versus pull, synchronous versus asynchronous, client versus server, or eliminating the work).
   - Check whether the scope is too narrow (missing a systemic cause) or too broad (premature generalization).

## Output format

Present the critique as a single numbered sequence of complete grammatical sentences with no bold text, no em dashes, and no `Label: value` prefixes:

1. State the actual problem in one sentence, naming if the user's proposal targets a symptom or the wrong problem.
2. State the primary flaw or hidden assumption in the current approach.
3. Name the problem archetype and the domain pattern that applies.
4. Rank 2 to 3 alternative approaches by effectiveness, stating the concrete tradeoffs of each.
5. Ask the minimum clarifying questions needed to choose or execute an approach (omit if none are needed), then stop.
