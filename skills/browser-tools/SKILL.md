---
name: browser-tools
description: >-
  Selecting and running browser tooling: Chrome DevTools MCP by default, browser-harness as the fallback,
  Chrome isolation for concurrent sessions, and the mandatory browser-harness execution order. Load before
  launching or attaching to any browser for web development, debugging, QA, scraping, or site automation.
---
# Browser tools

## Tool selection

Resolve web tasks in this order:

1. For web search, research, or documentation, use built-in search, fetch, and documentation tools. Do not launch or attach to a browser unless interaction with or inspection of the rendered page is necessary.
2. For a third-party service with an available MCP server or API, follow the `external-services` skill unless the visible UI itself is the source of truth.
3. When a browser is required, use Chrome DevTools MCP by default. This includes web development, debugging, performance work, accessibility inspection, repeatable QA, DOM inspection, console and network analysis, Lighthouse, memory analysis, and browser emulation.
4. Use `browser-harness` only when the task needs a capability Chrome DevTools MCP does not provide or cannot complete: open-ended web operations requiring custom recovery, arbitrary Python or direct raw CDP, custom or persistent site helpers, or Browser Use cloud integration. Treat it as the powerful fallback, not the default browser tool.
5. State why before switching tools. Do not use fallback tooling to bypass authentication, authorization, or consent.
6. Before using `browser-harness` with an authenticated or internal application, run `browser-harness telemetry status` and, if enabled, run `browser-harness telemetry disable`.
7. Validate browser work from rendered or runtime state with screenshots, DOM or accessibility reads, console or network evidence, or another direct observation appropriate to the task.

## Chrome requirement and session isolation

Browser automation must use Google Chrome explicitly. Chrome DevTools MCP may launch Chrome or connect to it through its own supported configuration. Do not use Vivaldi, Firefox, Chromium, or another browser unless the user explicitly overrides this requirement.

When more than one browser session may run at the same time, each session must drive its own isolated Chrome instance (a distinct user profile directory and its own remote debugging port) so sessions never share a profile, pages, or a debugging endpoint. Let Chrome DevTools MCP manage its own isolated Chrome instance rather than pointing several sessions at one shared Chrome. Never launch or attach to a single fixed debugging port from more than one session; a shared endpoint is the cause of cross-session conflicts and contention.

## browser-harness execution

When the routing rules select `browser-harness`, follow this mandatory order. Each task drives its own isolated Google Chrome instance so simultaneous sessions never share a profile or a debugging endpoint.

1. Read the `browser-harness` skill.
2. Launch a dedicated Google Chrome for this session with a unique profile directory and its own remote debugging port, for example `google-chrome --user-data-dir="$(mktemp -d)" --remote-debugging-port=0 <url>`. A port of `0` lets Chrome pick a free port and record it, which avoids collisions between sessions. Never reuse another session's profile or port, and never attach to a single fixed shared port.
3. Read this session's own CDP WebSocket endpoint from the Chrome instance you just launched (the `DevToolsActivePort` file in that profile directory, or the `webSocketDebuggerUrl` from `http://127.0.0.1:<port>/json/version`). Use that value as `BU_CDP_WS` for every `browser-harness` command in this task.
4. Do not rely on `browser-harness` default attachment, existing browser sessions, default browser handlers, a shared fixed debugging port, or Chromium-compatible browsers.
5. If `browser-harness` opens or attaches to any non-Google-Chrome browser, or to a Chrome instance you did not launch for this session, stop immediately and report failure.
6. Run the requested browser action with `BU_CDP_WS="$ws" browser-harness` only after verifying the controlled browser is the Google Chrome instance you launched for this session.
7. If `browser-harness` fails in any way, the very next command must be `browser-harness --doctor`.
8. Failures include non-zero exit, traceback, import error, command not found, connection error, timeout, hang, or unexpected daemon behavior.
9. Before `browser-harness --doctor` has run, do not debug, patch, reinstall, inspect wrappers, retry, or use `curl`, `WebFetch`, Playwright, or another browser.
10. If `browser-harness --doctor` reports the Chrome connection as `"FAIL"`, relaunch this session's isolated Chrome (step 2) and retry the original command with the new `BU_CDP_WS`.
11. If Chrome asks for the remote debugging checkbox or permission popup, stop and ask the user to approve it.
