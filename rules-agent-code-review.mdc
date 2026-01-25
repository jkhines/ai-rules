---
command: /code-review
description: Reviews two branches and provides feedback
alwaysApply: false
---
Review code changes between two user-specified branches. The user provides both branch names (e.g., `feature/auth` and `main`).

## Process

### 1. Fetch and Scope the Diff
```bash
git fetch origin
git diff --name-only origin/<base>...origin/<feature>
```
For each file, verify actual changes exist with `git diff --quiet`. Skip files with no diff hunks.

**Critical**: Use Git commands to read branch contents, not filesystem tools. The working directory may be a different branch.
- Check file existence: `git ls-tree -r --name-only origin/<branch> -- <path>`
- Read file contents: `git show origin/<branch>:<path>`

### 2. Evaluate Each Change
For each changed hunk, understand how the modified code interacts with surrounding logic: how inputs are derived, how outputs are consumed, and whether the change introduces side effects.

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

### 3. Format Issues
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
