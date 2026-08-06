---
name: external-services
description: >-
  Credentials, environment variables, and API conventions for third-party services (Jira, Confluence,
  GitHub, SonarQube, Auth0, AWS, SendGrid, TestRail, Terraform Enterprise, and others). Load before any
  interaction with a third-party service or API, whether through an MCP server or a direct API call.
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
| SonarQube | `SONAR_TOKEN` |
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

- Assume Cloud-hosted services unless told otherwise. Use the latest stable API version (confirm with Context7 via `CONTEXT7_KEY`). Always handle pagination; never assume one response contains all results.
- If a service is not listed, check for an MCP server first (`ToolSearch`), then the environment (`env | grep -i <service>`).

## Authentication (when not using MCP)

- Jira / Confluence: HTTP Basic Auth, `*_EMAIL` as username and `*_API_TOKEN` as password; use `*_BASE_URL` as the host, never a hand-built URL.
- GitHub: prefer the `gh` CLI; fall back to the raw API with `GITHUB_PAT` as Bearer token only when `gh` cannot do it.
- SonarQube: `SONAR_TOKEN` as Bearer token.
- TestRail: HTTP Basic Auth against `TESTRAIL_URL` as the host, `TESTRAIL_USERNAME` (account email) as username and `TESTRAIL_API_KEY` as password; API v2 base path `/index.php?/api/v2/`.
- Auth0: client ID, secret, and domain for the target environment (sb/dev/prod).
- SendGrid: Bearer token against `https://api.sendgrid.com/v3` (prefer `SENDGRID_RESTRICTED_API_KEY`; use `SENDGRID_ADMIN_API_KEY` only when broader scope is required). Email Activity feed: `GET /v3/messages?query=...` (query language, e.g. `last_event_time BETWEEN TIMESTAMP "..." AND TIMESTAMP "..."`).
- AWS: use the AWS CLI with the named profiles in `~/.aws/config` (`sb`, `dev`, `prod`) and always pass `--profile <name>`. Use env credentials only when a profile is unavailable or the user directs it.
