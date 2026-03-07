---
command: /feature-branch
description: Creates a feature branch following team naming conventions with Jira ticket traceability
alwaysApply: false
---

## Feature Branch Creation

Creates a new branch following team naming conventions defined in the Team Development Standards.

### Branch Naming Convention

```
<type>/<jira-id>-<short-description>
```

- `<type>` (Required): One of `feature`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `build`, `hotfix`.
  Use `feature` for new features (not `feat`).
- `<jira-id>` (Required): The Jira ticket ID (e.g., `PROJ-451`). Must be included for traceability.
  Joined to the description with a hyphen, not a path separator.
- `<short-description>` (Required): Short summary in English -- lowercase letters, words separated by hyphens,
  no accents or special characters (only `a-z`, `0-9`, and `-`). Brief and clear.

### Examples

```
feature/PROJ-451-implement-social-login
fix/APP-112-fix-shopping-cart-bug
refactor/PROJ-501-simplify-notification-service
```

## Execution Steps

When `/feature-branch` is invoked:

1. **Check for Jira Ticket**
   - If the user did not provide a Jira ticket number (e.g., `PROJ-123`), prompt them for it and stop. Do not
     proceed until a ticket number is provided.
   - Validate the format matches a Jira ticket pattern: one or more uppercase letters, a hyphen, then one or
     more digits (e.g., `PROJ-123`, `APP-42`).

2. **Fetch Ticket Summary from Jira**
   - Use the Jira API to fetch the ticket summary. Use `JIRA_BASE_URL`, `JIRA_EMAIL`, and `JIRA_API_TOKEN`
     from the environment for authentication (HTTP Basic Auth).
   - Endpoint: `GET {JIRA_BASE_URL}/rest/api/3/issue/{jira-id}?fields=summary,issuetype`
   - Extract the summary and issue type to inform the branch type and description.

3. **Determine Branch Type**
   - Map the Jira issue type to a branch type:
     - Bug -> `fix`
     - Story, Task, or feature-like types -> `feature`
     - Sub-task -> infer from parent or default to `feature`
     - Other -> `chore`
   - If the mapping is ambiguous, ask the user which type to use.

4. **Generate Branch Name**
   - Convert the ticket summary into a short kebab-case description:
     - Lowercase only.
     - Replace spaces and special characters with hyphens.
     - Remove accents and non-ASCII characters.
     - Strip leading/trailing/consecutive hyphens.
     - Keep it concise (aim for 3-6 words).
   - Assemble: `<type>/<jira-id>-<short-description>`
   - Present the proposed branch name to the user for confirmation.

5. **Determine Base Branch**
   - The base branch is `main`.
   - Fetch the latest version of `main` before creating the new branch.

6. **Create and Switch to the Branch**
   - Run `git fetch origin`
   - Run `git checkout -b <branch-name> --no-track origin/<base-branch>`
   - Run `git push -u origin <branch-name>` to set the upstream tracking branch.
   - Confirm the branch was created and is active.

7. **Summary**
   - Display the new branch name, base branch, and Jira ticket link.
