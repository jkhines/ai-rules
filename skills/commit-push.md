---
command: /commit-push
description: Commits code changes following Conventional Commits v1.0.0 and validates branch naming
alwaysApply: false
---

## Conventional Commits (v1.0.0)

### Commit Message Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types (REQUIRED)
- `feat`: New feature for the user (correlates with MINOR in SemVer)
- `fix`: Bug fix for the user (correlates with PATCH in SemVer)
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, missing semi-colons, whitespace, etc.) that do not affect code meaning
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes to build system or external dependencies (e.g., npm, webpack, gradle)
- `ci`: Changes to CI configuration files and scripts (e.g., GitHub Actions, CircleCI)
- `chore`: Other changes that don't modify src or test files (e.g., updating dependencies, tooling)
- `revert`: Reverts a previous commit

### Scope (OPTIONAL)
- Noun describing a section of the codebase enclosed in parentheses
- Examples: `feat(parser):`, `fix(api):`, `refactor(auth):`

### Description (REQUIRED)
- Short summary in present tense (imperative mood)
- No capitalized first letter
- No period at the end
- Examples: "add user authentication", "fix memory leak in parser"

### Body (OPTIONAL)
- Provide additional contextual information
- Use imperative mood
- May contain multiple paragraphs
- Separate from description by one blank line

### Footer (OPTIONAL)
- One or more footers separated from body by one blank line
- Format: `<token>: <value>` or `<token> #<issue-number>`
- Common tokens: `BREAKING CHANGE`, `Refs`, `Closes`, `Fixes`
- BREAKING CHANGE footer triggers MAJOR version bump (or append `!` after type/scope)

### Breaking Changes
- MUST be indicated by appending `!` after type/scope: `feat!:` or `feat(api)!:`
- OR by including `BREAKING CHANGE:` footer with description
- Example:
  ```
  feat!: remove deprecated v1 API
  
  BREAKING CHANGE: v1 API endpoints have been removed. Use v2 instead.
  ```

### Examples
```
feat(auth): add OAuth2 support

fix: resolve race condition in event loop

docs(readme): update installation instructions

feat!: remove support for Node 12

BREAKING CHANGE: Node 12 is no longer supported. Minimum version is now Node 14.

refactor(core)!: simplify API surface

BREAKING CHANGE: The `initialize()` method now requires a config object.

chore: update dependencies

test(parser): add tests for edge cases

ci: add automated release workflow
```

## Conventional Branch Naming

### Branch Format
```
<type>/<description>
```

### Branch Types (REQUIRED)
- `main` or `master` or `develop`: Main development branch (no type prefix)
- `feature/` or `feat/`: New features
- `bugfix/` or `fix/`: Bug fixes
- `hotfix/`: Urgent production fixes
- `release/`: Release preparation branches
- `chore/`: Maintenance tasks, dependency updates, tooling
- `docs/`: Documentation only changes
- `refactor/`: Code refactoring without behavior change
- `test/`: Test additions or corrections
- `perf/`: Performance improvements
- `ci/`: CI/CD configuration changes

### Description (REQUIRED)
- Use lowercase letters (a-z), numbers (0-9), and hyphens (-) only
- Separate words with hyphens
- No special characters, underscores, or spaces
- No consecutive, leading, or trailing hyphens or dots
- Keep concise and descriptive
- Include ticket/issue numbers when applicable
- For release branches, dots (.) allowed for version numbers

### Examples
```
feature/user-authentication
feat/add-payment-gateway
bugfix/fix-login-timeout
fix/resolve-memory-leak
hotfix/security-patch-cve-2024
release/v1.2.0
chore/update-dependencies
docs/api-documentation
refactor/simplify-error-handling
test/add-integration-tests
perf/optimize-database-queries
ci/add-deployment-pipeline
feature/issue-123-add-dark-mode
```

## Execution Steps

When `/commit-push` is invoked:

- Automatically stage all changes, commit with a self-determined Conventional Commit message, and push to the remote. Do not prompt for any confirmation.

1. **Check Git Status**
   - Run `git status` to identify staged and unstaged changes
   - If no changes are present, inform the user and exit

2. **Validate Current Branch**
   - Run `git branch --show-current` to get the current branch name
   - Check if branch name matches pattern: `<type>/<description>`
   - Valid types: `feature/`, `feat/`, `bugfix/`, `fix/`, `hotfix/`, `release/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`, `ci/`
   - Exception: `main`, `master`, `develop` are valid without prefix
   
3. **If Branch is Non-Standard**
   - Warn: "Branch '[branch-name]' does not follow conventional naming. Proceeding anyway."
   - Continue to commit step

4. **Analyze Changes**
   - Review the staged/unstaged changes
   - Determine appropriate commit type based on changes:
     - `feat`: New functionality added
     - `fix`: Bug fixes
     - `docs`: Documentation changes only
     - `style`: Formatting, whitespace changes
     - `refactor`: Code restructuring without behavior change
     - `perf`: Performance improvements
     - `test`: Test additions or modifications
     - `build`: Build system or dependency changes
     - `ci`: CI/CD configuration changes
     - `chore`: Maintenance tasks
   - Detect breaking changes by looking for:
     - Removed or renamed public APIs, functions, classes, or exports
     - Changed function signatures (parameters added/removed/reordered)
     - Changed return types or data structures
     - Removed configuration options or environment variables
     - Changed default behavior

5. **Generate Commit Message**
   - Determine a commit message following the format:
     ```
     <type>[optional scope]: <description>

     [optional body]

     [optional footer]
     ```
   - Rules:
     - Type is one of the allowed types
     - Omit scope unless the affected area is obvious from file paths
     - Description is present and in imperative mood
     - Description starts with lowercase letter
     - Description does not end with a period
     - If breaking changes detected, append `!` after type and include `BREAKING CHANGE:` footer

6. **Execute Commit**
   - Stage all changes: `git add -A`
   - Execute: `git commit -m "<commit-message>"`
   - Confirm commit was successful

7. **Push to Remote**
   - Detect upstream tracking branch: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
   - If tracking branch exists, push to it; otherwise push to `origin` with current branch name
   - Execute: `git push`

8. **Post-Commit Summary**
   - Show commit hash, message, and push destination
