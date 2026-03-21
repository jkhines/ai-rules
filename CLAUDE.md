---
name: formatting-and-behavior
description: Global behavior, generation, and formatting rules
alwaysApply: true
---
## Behavior
- Never use emojis.
- Factual, accurate answers with minimal but sufficient expert-level context.
- If no correct answer exists, say so. Never fabricate or speculate; ask clarifying questions instead.
- Only state conclusions you are over 90% confident in. If below 90%, state what the evidence shows and what you do not know. Never guess at actions taken by others or causes not directly supported by evidence.
- Never state a definitive conclusion before completing your analysis. Finish reasoning first, then lead with the correct answer. A response that opens with one answer and concludes with the opposite is worse than a slower, correct response.

## Generation
- Write code only when at least 95% confident in requirements. If below 95%, state confidence and ask clarifying questions.
- Code must be correct, secure, and fully functional with all required imports.
- Prioritize readability. Note security or efficiency considerations.

## Formatting
- Do not break lines unless they exceed 120 characters.
- Never remove existing inline comments.
- Only add comments when code may be non-obvious to an expert. Use complete, capitalized sentences with a period. One space between code and comment. No emojis, ASCII formatting, arrows, or extra spaces in comments.

## Programming
- Use yarn and uv, not npm and pip.
- For substantial changes (not trivial one-liners), before writing source code:
  1. State how you will verify the change works (test, bash command, browser check, etc.)
  2. Write the test or verification step first
  3. Implement the code
  4. Run the verification and iterate until it passes

## External Systems — MANDATORY

Before ANY interaction with a third-party service or API:
1. Check the shell environment for required credentials and use them. NEVER skip this step.
2. Read credential values using `env | grep VAR_NAME | cut -d= -f2-`, NOT `$VAR` or `echo "$VAR"` which may appear empty due to shell sandboxing. Use command substitution (e.g., `"$(env | grep TFE_TOKEN | cut -d= -f2-)"`) to pass values to commands.
3. NEVER attempt unauthenticated requests, browser-based login, public URLs, OAuth flows, or prompt the user for credentials available in the environment.
4. If a required variable is not set, say so and stop.

Environment variables — use these for their respective services:

| Service | Variables |
|---|---|
| Jira Cloud | `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| Confluence Cloud | `CONFLUENCE_BASE_URL`, `CONFLUENCE_EMAIL`, `CONFLUENCE_API_TOKEN` |
| GitHub | `GITHUB_PAT` |
| SonarQube | `SONAR_TOKEN` |
| DeepL | `DEEPL_AUTH_KEY` |
| PyPI / Twine | `TWINE_USERNAME`, `TWINE_PASSWORD`, `TWINE_TEST_USERNAME`, `TWINE_TEST_PASSWORD` |
| Lucidchart | `LUCID_API_KEY` |
| Context7 | `CONTEXT7_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Terraform Enterprise | `TFE_TOKEN` |
| Resend | `RESEND_API_KEY` |
| Auth0 (sandbox) | `AUTH0_SB_CLIENT_ID`, `AUTH0_SB_CLIENT_SECRET`, `AUTH0_SB_DOMAIN` |
| Auth0 (dev) | `AUTH0_DEV_CLIENT_ID`, `AUTH0_DEV_CLIENT_SECRET`, `AUTH0_DEV_DOMAIN` |
| Auth0 (prod) | `AUTH0_PROD_CLIENT_ID`, `AUTH0_PROD_CLIENT_SECRET`, `AUTH0_PROD_DOMAIN` |
| AWS | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION` |

General rules:
- Assume Cloud-hosted versions of all services unless told otherwise.
- Use the latest stable API version. Use Context7 (`CONTEXT7_KEY`) to confirm API versions and usage before making calls.
- Always handle pagination. Never assume a single response contains all results.

Authentication:
- Jira / Confluence: HTTP Basic Auth with the service-specific `*_EMAIL` as username and `*_API_TOKEN` as password. Use `*_BASE_URL` as the host — never construct URLs from scratch.
- GitHub: Prefer `gh` CLI for all operations. Fall back to raw API with `GITHUB_PAT` as Bearer token only when `gh` cannot accomplish the task.
- SonarQube: `SONAR_TOKEN` as Bearer token.
- Auth0: Client ID, client secret, and domain for the appropriate environment (sb/dev/prod).
- AWS: Use the AWS CLI. Prefer the named profiles in `~/.aws/config`: `sb` for sandbox, `dev` for development, `prod` for production, and always pass `--profile <name>`. Only use environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) when a required profile is unavailable or you are explicitly directed to use env credentials.

If the service is not listed above, check the environment anyway (`env | grep -i <service>`).

## Documentation Lookup
- Use `CONTEXT7_KEY` to fetch current documentation before writing code with external libraries. Prefer up-to-date docs over training knowledge.

## System Requirements
- Detect POP!_OS 24.04 or CachyOS Linux. Assume COSMIC desktop, Wayland. Use bash syntax.
- On CachyOS (and other Arch-based systems), prefer paru over yay when installing packages from AUR or official repos.
