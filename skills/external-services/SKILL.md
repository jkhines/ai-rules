---
name: external-services
description: Load before using any third-party service, authenticated URL, or DeepL (Jira, Confluence, GitHub, SonarQube, Auth0, AWS, SendGrid, TestRail, TFE, Secret Server, Fastmail, Dynatrace): MCP first, then env vars.
---
# External services

Before any interaction with a third-party service or API, resolve in this order.

1. Use the service's MCP server when one is available (check via `ToolSearch`), except for two cases that require direct API calls: reading Jira custom field values (which `Atlassian-MCP-Server` strips from `getJiraIssue` and `searchJiraIssuesUsingJql` responses) and reading or sending Fastmail mail or contacts (use `FASTMAIL_API_TOKEN` against JMAP; use the Fastmail MCP server only for calendars). For all other Jira and Confluence work, use `Atlassian-MCP-Server`.
2. Otherwise use environment variables and direct API calls:
   - Never attempt unauthenticated requests, browser-based login, public URLs, OAuth flows, or prompt the user for credentials that exist in the environment. If a required variable is not set, say so and stop.
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
| Fastmail | `FASTMAIL_API_TOKEN` |
| Dynatrace | `DYNATRACE_BASE_URL`, `DYNATRACE_TOKEN` |

- Assume Cloud-hosted services unless told otherwise. Use the latest stable API version (confirm with Context7 via `CONTEXT7_KEY`). Always handle pagination; never assume one response contains all results.
- If a service is not listed, check for an MCP server first (`ToolSearch`), then the environment (`env | grep -i <service>`).

## Authentication (when not using MCP)

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
- Fastmail: use `FASTMAIL_API_TOKEN` for mail and contacts, even when the Fastmail MCP server is available. Send it as a Bearer token, call `https://api.fastmail.com/jmap/session` first, then use the returned `apiUrl` and mail `accountId`. Use the Fastmail MCP server only for calendars, because the token's JMAP session has no calendars capability.
- Dynatrace: `DYNATRACE_TOKEN` is a platform token (prefix `dt0s16.`). Send it as `Authorization: Bearer <token>` against `DYNATRACE_BASE_URL` as the host. Reach Classic Environment API v2 endpoints through `/platform/classic/environment-api/v2/`. If `DYNATRACE_BASE_URL` is not set, say so and stop. Never guess or probe the tenant host.
