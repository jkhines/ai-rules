---
name: external-services
description: >-
  Prefer MCP servers over direct API calls, and use environment credentials for third-party services
  (Jira, Confluence, GitHub, SonarQube, Auth0, AWS, SendGrid, TestRail, Terraform Enterprise, DeepL,
  Delinea Secret Server, and others). Load before any interaction with a third-party service or API,
  when retrieving web content behind a login, or when translating content with DeepL.
---
# External services

Before any interaction with a third-party service or API, resolve in this order.

1. **Prefer MCP servers.** If one is available for the service (check via `ToolSearch`), use it. It handles auth, pagination, and API versioning. Do not fall back to direct API calls when an MCP tool can do the job. For Jira and Confluence, always use the `Atlassian-MCP-Server` tools (`searchJiraIssuesUsingJql`, `getJiraIssue`, `getConfluencePage`, `searchConfluenceUsingCql`).
2. **Otherwise use environment variables and direct API calls.**
   - **Mandatory credentials:** Never attempt unauthenticated requests, browser-based login, public URLs, OAuth flows, or prompt the user for credentials that exist in the environment. If a required variable is not set, say so and stop.
   - Read credential values with `env | grep VAR_NAME | cut -d= -f2-`, not `$VAR` or `echo "$VAR"` (which may appear empty under shell sandboxing). Pass them via command substitution, e.g. `"$(env | grep TFE_TOKEN | cut -d= -f2-)"`.

## Environment variables

Use these for their respective services:

| Service | Variables |
|---|---|
| Jira Cloud | `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| Confluence Cloud | `CONFLUENCE_BASE_URL`, `CONFLUENCE_EMAIL`, `CONFLUENCE_API_TOKEN` |
| GitHub | `GITHUB_PAT` |
| SonarQube | `SONAR_ADMIN_TOKEN` |
| DeepL | `DEEPL_AUTH_KEY` |
| PyPI / Twine | `TWINE_USERNAME`, `TWINE_PASSWORD`, `TWINE_TEST_USERNAME`, `TWINE_TEST_PASSWORD` |
| Lucidchart | `LUCID_API_KEY` |
| Context7 | `CONTEXT7_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Terraform Enterprise | `TFE_TOKEN` |
| Resend | `RESEND_API_KEY` |
| SendGrid | `SENDGRID_ADMIN_API_KEY`, `SENDGRID_RESTRICTED_API_KEY` |
| Auth0 (sandbox) | `AUTH0_SB_CLIENT_ID`, `AUTH0_SB_CLIENT_SECRET`, `AUTH0_SB_DOMAIN` |
| Auth0 (dev) | `AUTH0_DEV_CLIENT_ID`, `AUTH0_DEV_CLIENT_SECRET`, `AUTH0_DEV_DOMAIN` |
| Auth0 (prod) | `AUTH0_PROD_CLIENT_ID`, `AUTH0_PROD_CLIENT_SECRET`, `AUTH0_PROD_DOMAIN` |
| AWS | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION` |
| TestRail | `TESTRAIL_URL`, `TESTRAIL_USERNAME`, `TESTRAIL_API_KEY` |
| Delinea Secret Server | `SECRETSERVER_BASE_URL`, `SECRETSERVER_API_KEY` |

- Assume Cloud-hosted services unless told otherwise. Use the latest stable API version (confirm with Context7 via `CONTEXT7_KEY`). Always handle pagination; never assume one response contains all results.
- If a service is not listed, check for an MCP server first (`ToolSearch`), then the environment (`env | grep -i <service>`).

## Authentication (when not using MCP)

- Jira through the Atlassian MCP server: read responses (`getJiraIssue`, `searchJiraIssuesUsingJql`) drop custom fields whatever `fields` requests, although JQL filters on custom fields work. When a task must read a custom field value, use the REST API with the `JIRA_*` variables below.
- Jira / Confluence: HTTP Basic Auth, `*_EMAIL` as username and `*_API_TOKEN` as password; use `*_BASE_URL` as the host, never a hand-built URL.
- GitHub: prefer the `gh` CLI; fall back to the raw API with `GITHUB_PAT` as Bearer token only when `gh` cannot do it.
- GitHub: when a `gh` command fails with a permission, not-found, or SSO error, run `gh auth status`. If another signed-in account belongs to the repository's organization, run `gh auth switch` to that account and retry. Never override the account with `GH_TOKEN`.
- SonarQube: `SONAR_ADMIN_TOKEN` as Bearer token.
- DeepL: load the `translate` skill first. Use the `translate` command line tool when it is on `PATH`, or call the DeepL API with `DEEPL_AUTH_KEY` or `DEEPL_API_KEY` when no file is involved. When neither is available, state that DeepL is unavailable before answering, and label the result as an agent translation rather than DeepL output.
- TestRail: HTTP Basic Auth against `TESTRAIL_URL` as the host, `TESTRAIL_USERNAME` (account email) as username and `TESTRAIL_API_KEY` as password; API v2 base path `/index.php?/api/v2/`.
- Auth0: client ID, secret, and domain for the target environment (sb/dev/prod).
- SendGrid: Bearer token against `https://api.sendgrid.com/v3` (prefer `SENDGRID_RESTRICTED_API_KEY`; use `SENDGRID_ADMIN_API_KEY` only when broader scope is required). Email Activity feed: `GET /v3/messages?query=...` (query language, e.g. `last_event_time BETWEEN TIMESTAMP "..." AND TIMESTAMP "..."`).
- AWS: use the AWS CLI with the named profiles in `~/.aws/config` (`sb`, `dev`, `prod`) and always pass `--profile <name>`. Use env credentials only when a profile is unavailable or the user directs it.
- Delinea Secret Server: `SECRETSERVER_API_KEY` as Bearer token against `SECRETSERVER_BASE_URL` with the base path `/api/v1` (not `/SecretServer/api/v1`, which redirects to the login page). Never guess or probe the tenant host; if `SECRETSERVER_BASE_URL` is not set, say so and stop. The key is a short-lived token from the user's Secret Server preferences (**API Token** > **Generate API Token and Copy to Clipboard**), and it expires after the tenant's "Session Timeout for Webservices" (Delinea default: 20 minutes). Call `GET /api/v1/users/current` first; on `401 "Authentication failed or expired token."`, stop, ask the user to generate a new token, and offer the manual web-interface steps when the task is only a few clicks.
