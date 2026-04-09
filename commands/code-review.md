---
command: /code-review
description: Reviews two branches and provides feedback
alwaysApply: false
---
Review code changes between two branches. By default, compare the current branch against `main`. The user may override either branch explicitly (e.g., `/code-review feature/auth dev`).

## Severity Definitions

Classify every finding into exactly one of these levels:

| Severity | Definition | Examples |
|----------|-----------|----------|
| **Critical** | Will cause data loss, security breach, or complete service outage in production. Must be fixed before merge. | SQL injection, unvalidated redirect to attacker-controlled URL, missing authZ on a mutation endpoint, uncaught exception that crashes the process |
| **Major** | Will cause incorrect behavior, security weakness, meaningful performance degradation, or data integrity risk. Should be fixed before merge. | Race condition in concurrent writes, missing input validation on external API boundary, N+1 query in a list endpoint, error swallowed silently hiding failures from operators |
| **Minor** | Code quality, maintainability, or style issue that does not affect runtime correctness or security. Fix is desirable but not blocking. | Inconsistent naming, missing type annotation on a public API, duplicated constant, unclear variable name |
| **Enhancement** | Improvement suggestion or alternative approach. Not a defect. | Suggest extracting a helper, propose a more idiomatic pattern, recommend adding a metric |

When in doubt between two adjacent levels, prefer the higher severity. A finding that straddles Critical/Major should be Critical; one that straddles Major/Minor should be Major.

## Process

### 1. Resolve Branches and Fetch
Determine the branches to compare:
- **Feature branch**: first positional argument, or the current branch (`git branch --show-current`). If the current branch is `main`, ask the user which branch to review.
- **Base branch**: second positional argument, or `main`.

#### Ref resolution
For each branch name, resolve it to a concrete git ref using this priority order:
1. If HEAD is on that branch and the local ref exists, use the **local** ref (so unpushed commits are included).
2. Otherwise, if `origin/<name>` exists, use the **remote** ref.
3. Otherwise, if the local ref exists, use it.
4. If neither exists, stop and report the error.

```bash
git fetch origin
# Resolve refs (example: feature branch is local, base is remote)
git rev-parse --verify <feature>          # check local
git rev-parse --verify origin/<feature>   # check remote
git rev-parse --verify <base>
git rev-parse --verify origin/<base>
```

#### Compute the diff via merge-base
Use `git merge-base` to find the common ancestor, then diff from that point. This correctly scopes the diff to only changes introduced on the feature branch, even after rebases or merges into the base.

```bash
MERGE_BASE=$(git merge-base <resolved-base> <resolved-feature>)
git diff --name-only $MERGE_BASE <resolved-feature>
```

If `git merge-base` fails, stop and report the error.

For each file in the diff output, verify actual changes exist with `git diff --quiet`. Skip files with no diff hunks.

**Critical**: Use Git commands to read branch contents, not filesystem tools. The working directory may be a different branch.
- Check file existence: `git ls-tree -r --name-only <resolved-feature> -- <path>`
- Read file contents: `git show <resolved-feature>:<path>`

For each changed file, read the full file with `git show <resolved-feature>:<path>` to understand:
- The complete function, class, or module containing each change
- Imports and dependencies affected by the change
- How callers or consumers use the modified code
- Whether similar patterns exist elsewhere that should change consistently

Do not review the diff in isolation. A change that looks correct in a hunk may break invariants visible only in the full file.

If a change modifies an interface, type, config key, or export, use `git ls-tree` and `git show` (with the resolved feature ref) to read all files that import or consume it and verify they remain compatible.

### 2. Gather Organizational Context

If an Unblocked context engine tool is available (e.g., `unblocked_context_engine`), query it for context that a diff-based review would miss. If the tool is not available, skip this step and proceed to step 3.

Call the tool with:
- `projectPath`: the current working directory
- `question`: a query that includes the feature branch name and the list of changed files from step 1, asking for:
  - Team standards or conventions documented in wikis or knowledge bases
  - Relevant past PR discussions, reviewer feedback, or decisions
  - Related Slack or messaging threads about these modules or patterns
  - Known issues, tickets, or constraints from issue trackers
  - Architectural decisions or design rationale from any source

Focus the query on what reviewers need to know that is NOT visible in the diff itself.

Save the response as the **ORGANIZATIONAL CONTEXT** for use in step 3.

### 3. Evaluate Each Change
For each changed hunk, use your understanding of the full file and its dependents to assess the change. Identify how inputs are derived, how outputs are consumed, and whether the change introduces side effects.

Assess against these criteria (mark N/A if not applicable to this change):

| Category | Check |
|----------|-------|
| Design | Fits architectural patterns, avoids coupling, clear separation of concerns |
| Complexity | Flat control flow, low cyclomatic complexity, DRY, no dead code |
| Correctness | Handles valid/invalid inputs, edge cases, error paths, idempotency |
| Readability | Clear naming, comments explain why not what, logical ordering |
| Patterns | Language idioms, SOLID principles, resource cleanup, logging |
| Tests | Unit + integration coverage, meaningful assertions, descriptive names |
| Style | Conforms to style guide, no new linter warnings |
| Documentation | Public APIs documented, README/CHANGELOG updated if needed |
| Security | Input validation, output encoding, secrets management, authZ/authN |
| Performance | No N+1 queries, efficient I/O, appropriate caching/batching |
| Observability | Metrics/tracing for key events, appropriate log levels, no sensitive data logged |
| Accessibility | Semantic HTML, ARIA attributes, keyboard nav, i18n strings externalized |
| CI/CD | Pipeline integrity, dependency declarations, deployment strategy |
| Code Quality | Consistent style, no hidden dependencies, tests and docs included |

If ORGANIZATIONAL CONTEXT was gathered in step 2, treat it as authoritative team-specific guidance. Prefer organizational conventions over generic best practices when they conflict. Flag deviations from documented team standards as at least Minor.

### 4. Apply "What Could Break" Lens
After evaluating each change against the criteria table, actively look for the failure modes below. If you already reported an issue from the criteria table that covers the same root cause, do not report it again here -- this lens is a second pass to catch what the table missed, not a source of duplicates.
- **Input boundaries**: Unvalidated or partially validated inputs, missing type guards, unhandled null/undefined
- **Edge cases**: Empty collections, concurrent access, off-by-one, boundary values
- **Error paths**: Swallowed exceptions, missing rollback after partial failure, cleanup that masks errors
- **Authorization and secrets**: Privilege escalation paths, credentials in logs or error messages, missing authZ checks on new endpoints
- **Observability gaps**: Key operations without logging, sensitive data in log output, missing error context
- **Deployment safety**: Migration ordering, backwards-incompatible config changes, feature flags not wired

For each item, check the full file and related files using `git show` -- not just the diff hunk. If the change introduces a new function, read its callers. If it modifies error handling, read the caller's catch blocks. If it changes a type, read all consumers.

### 5. Preserve Branch Intent
Identify the core purpose of the branch from the diff (e.g., adding a new resource, introducing an integration, implementing a feature). Issues that recommend **replacing or removing** the fundamental approach -- rather than improving it -- must be labeled **Advisory** and placed under Enhancement, not Critical or Major. A finding is Advisory when the only fix is to abandon the approach the branch exists to implement.

Critical and Major findings must be **actionable within the current approach**. For example, if the branch introduces an externally-imported certificate, "add lifecycle protections" is actionable; "import the certificate outside Terraform instead" is Advisory because it negates the branch's purpose.

### 6. Format Issues
For each issue:
```
- File: `<path>:<line-range>`
  - Issue: [One-line root problem]
  - Fix: [Suggested change or code snippet]
```

## Output Format

### High-Level Summary
2-3 sentences covering:
- **Product impact**: What this delivers for users/customers
- **Engineering approach**: Key patterns or frameworks used

### Prioritized Issues
Group all issues by severity. Include all four sections even if empty.

#### Critical
- ...

#### Major
- ...

#### Minor
- ...

#### Enhancement
- ...

### Highlights
Bulleted list of positive findings or well-implemented patterns.
