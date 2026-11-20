---
name: commit-push
description: Stage all changes, commit with a Conventional Commits message, and push without asking for confirmation.
disable-model-invocation: true
---
# Commit and push

Run this workflow only when the user invokes `/commit-push` by name. Stage all changes, commit with a Conventional Commits v1.0.0 message, and push to the remote without asking for confirmation.

## Execution steps

1. Check git status:
   - Run `git status` and `git diff` to inspect staged and unstaged changes.
   - If there are no changes to commit, tell the user and stop.
2. Check the current branch name:
   - Run `git branch --show-current`.
   - Accept `main`, `master`, `develop`, or `<type>/<description>` where `<type>` is `feature`, `feat`, `bugfix`, `fix`, `hotfix`, `release`, `chore`, `docs`, `refactor`, `test`, `perf`, or `ci` and `<description>` uses lowercase ASCII letters, digits, and single hyphens (plus dots in `release/`).
   - If the branch name does not match, warn `"Branch '<branch-name>' does not follow conventional naming. Proceeding anyway."` and continue.
3. Build the Conventional Commits v1.0.0 message:
   - Format: `<type>[optional (scope)][!]: <description>`, followed by an optional blank line and imperative body, and an optional blank line and footer (`BREAKING CHANGE: <detail>`, `Refs #<id>`, `Closes #<id>`, `Fixes #<id>`).
   - Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
   - Omit `(scope)` unless the affected component is obvious from the changed paths.
   - Write `<description>` in the imperative mood, starting with a lowercase letter and ending without a period.
   - Append `!` after the type or scope and add a `BREAKING CHANGE:` footer whenever the diff removes or renames a public API, changes a signature or return type, removes a configuration key or environment variable, or changes default behavior.
4. Commit and push:
   - Run `git add -A` and `git commit -m "<message>"`.
   - Detect the upstream tracking branch with `git rev-parse --abbrev-ref --symbolic-full-name @{u}`. Push to that upstream if set, or run `git push -u origin <branch>` if no upstream exists.
5. Report the short commit hash, the commit message, and the remote branch pushed.
