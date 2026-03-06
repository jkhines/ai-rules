---
command: /pull-request
description: Creates a pull request following team standards with Jira integration
alwaysApply: false
---

## Pull Request Creation

Creates a pull request following team standards defined in the Team Development Standards.

### PR Title Format

For development PRs, use Conventional Commits format with the Jira ticket ID in the scope position:

```
<type>(<jira-id>): <description>
```

Example: `feat(PROJ-451): implement social login`

If no Jira ticket is available but a module scope is appropriate:

```
<type>(<scope>): <description>
```

Example: `feat(ci): refine concurrency settings in publish workflow`

Keep the title concise but do not enforce a hard character limit. Aim for brevity; up to ~100 characters is
acceptable when the description requires it.

### PR Description Template

The repository's `.github/pull_request_template.md` provides the PR description structure. GitHub pre-fills
this template automatically when creating a PR. The command must populate the template sections with content
derived from the diff analysis rather than replacing the template with a custom format.

The standard template across team repositories is:

```markdown
### Jira Activity

[<jira-id>](<jira-browse-url>)

### What was done?

<!-- Clearly and concisely describe the changes made in this Pull Request, focusing on the purpose of the change. -->

### How to Test?

<!-- Provide a clear step-by-step guide for the reviewer to validate your changes. Be specific. -->

### Expected Result:

<!-- Describe what the reviewer should see or what should happen at the end of the tests. -->

### Risks and Impacts

<!-- List any risks or impacts that this change may cause (e.g., in other parts of the system, performance, etc.). If none, write "None". -->

### Screenshots / GIFs (if applicable)

### Author Checklist

[ ] My branch is up to date with `<base-branch>`.
[ ] I have added tests that cover my changes.
[ ] Relevant documentation has been updated.
```

Note: The Author Checklist must reference the actual base branch (e.g., `main`), not a placeholder.

## Execution Steps

When `/pull-request` is invoked:

1. **Check for Uncommitted Changes**
   - Run `git status` to check for staged or unstaged changes (including untracked files).
   - If there are any uncommitted changes, inform the user: "There are uncommitted changes on this branch.
     Please commit and push your changes first (e.g., `/commit-push`), then re-run `/pull-request`."
   - Stop execution. Do not proceed until the working tree is clean.

2. **Ensure Branch is Pushed**
   - Check if the current branch has an upstream tracking branch: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
   - If no upstream exists, push the branch: `git push -u origin <current-branch>`
   - If an upstream exists, check if there are unpushed commits: `git log @{u}..HEAD --oneline`
   - If there are unpushed commits, push them: `git push`

3. **Determine the Base Branch (Merge Target)**

   Git does not store parent-branch metadata, so every detection method is a heuristic. The strategy below
   layers multiple signals from most-reliable to least-reliable to converge on the correct answer.

   - **Step A -- Reflog hint (best-effort, may be unavailable):**
     - Run: `git reflog show <current-branch> --format='%gs' | tail -1`
     - Look for patterns: `branch: Created from origin/<branch>` or `branch: Created from <branch>`.
     - If `<branch>` is a branch name (not a raw SHA), record it as the reflog candidate.
     - The reflog expires (default 90 days) and format varies across Git versions, so treat this as a
       **hint only** -- it must be confirmed by Step B.

   - **Step B -- Merge-base topological comparison (primary method):**
     - Fetch latest remote state: `git fetch origin`
     - Build a candidate list of remote branches, prioritized in this order:
       1. The reflog candidate from Step A (if any).
       2. `main` (the team's long-lived branch).
       3. Any other remote branches that are not the current branch.
     - For each candidate, compute the merge-base:
       ```
       git merge-base origin/<candidate> HEAD
       ```
     - Collect all unique merge-base commits, then determine which one is **topologically nearest** to HEAD:
       ```
       git rev-list --topo-order --max-count=1 <merge-base-1> <merge-base-2> ...
       ```
       The commit returned is the most recent common ancestor across all candidates. The candidate branch
       that produced this merge-base is the base branch.
     - **Tie-breaking:** If multiple candidates share the same merge-base commit, prefer in this order:
       the reflog candidate from Step A, then `main`, then other branches alphabetically.

   - **Step C -- Validate with commit log:**
     - Run: `git log origin/<base>..HEAD --oneline`
     - Verify that the listed commits belong to the current feature work. If unrelated commits from other
       branches appear, the chosen base is likely wrong -- re-examine candidates from Step B, excluding the
       current choice, and repeat.

   - **Step D -- Handle deleted parent branches:**
     - If the reflog candidate from Step A no longer exists on the remote (`git ls-remote --heads origin <name>`
       returns empty), the parent branch was likely merged and deleted.
     - In this case, fall back to the merge-base winner from Step B among the remaining long-lived branches
       (`main`).

   - **Final confirmation:** Display the determined base branch to the user and ask for confirmation before
     proceeding. Example: "Detected base branch: `main`. Is this correct? (y/n)"
   - The confirmed base branch is the PR merge target. This may be `main` or another feature branch.

4. **Extract Jira Ticket from Branch Name**
   - Parse the current branch name for a Jira ticket ID matching the pattern `[A-Z]+-[0-9]+`.
   - If found, fetch the ticket summary from Jira using `JIRA_BASE_URL`, `JIRA_EMAIL`, and `JIRA_API_TOKEN`
     (HTTP Basic Auth). Endpoint: `GET {JIRA_BASE_URL}/rest/api/3/issue/{jira-id}?fields=summary,issuetype`
   - If no ticket ID is found in the branch name, ask the user for one or proceed without it.

5. **Analyze Changes for the PR**
   - Compute the diff between the current branch and the base branch determined in step 3:
     `git diff <base-branch>...HEAD`
   - Review the full commit log since divergence: `git log <base-branch>..HEAD --oneline`
   - Understand the full scope of changes -- all commits, not just the latest one.

6. **Generate PR Title**
   - Follow the format: `<type>(<jira-id>): <description>`
   - The `<type>` should match the branch type prefix, mapped to conventional commit types:
     `feature/` -> `feat`, `fix/` -> `fix`, `hotfix/` -> `fix`, `chore/` -> `chore`, etc.
   - Place the Jira ticket ID in the scope (parentheses) position.
   - If no Jira ticket is available, use a module scope or omit scope entirely.
   - Keep the title concise. Aim for brevity but up to ~100 characters is acceptable.

7. **Create the PR with the Default Template**
   - Check if the repository has a PR template at `.github/pull_request_template.md`.
   - If the template exists, create the PR using it as the initial body:
     ```
     gh pr create --base <base-branch> --title "<title>" --body-file .github/pull_request_template.md
     ```
   - If no template exists, create the PR with an empty body:
     ```
     gh pr create --base <base-branch> --title "<title>" --body ""
     ```
   - Record the PR number from the output.

8. **Generate Full PR Description**
   - If a PR template was used in step 7, use its section headings and placeholder comments as the base
     structure. Populate each section with content from the diff analysis in step 5, preserving the template
     headings. If no template exists, use the standard template defined in this command.
   - Fill in each section as follows:
     - **Jira Activity** -- Link to the Jira ticket: `[<jira-id>](https://<jira-base-url>/browse/<jira-id>)`.
       If no Jira ticket, write "None".
     - **What was done?** -- Summarize the changes as a bullet list. Use **bold lead-ins** for each item
       when multiple areas are affected (e.g., `- **Auth module**: Refactored JWT validation...`).
       Focus on the purpose of the change, not line-by-line diffs.
     - **How to Test?** -- Provide specific numbered steps to validate the changes.
     - **Expected Result:** -- Describe what the reviewer should observe after following the test steps.
     - **Risks and Impacts** -- Note any risks, breaking changes, or side effects. Write "None" if none.
     - **Screenshots / GIFs** -- Write "N/A" if not applicable.
     - **Author Checklist** -- Include the three checklist items (unchecked), with the base branch name
       substituted into the first item: `[ ] My branch is up to date with \`<base-branch>\`.`

9. **Update the PR Description**
   - Update the PR body with the full description:
     ```
     gh pr edit <pr-number> --body "<full-description>"
     ```
   - Use a HEREDOC for correct formatting.

10. **Summary**
    - Display the PR URL, title, base branch, and Jira ticket link (if applicable).
    - Remind the user of the review requirements:
      - PRs to `main`: Requires senior involvement (as author or reviewer).
      - Review SLA: 2 business days for `main`.
