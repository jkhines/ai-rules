---
name: browser-tools
description: >-
  Retrieve public web content with built-in search and fetch tools, retrieve authenticated content
  through MCP servers or APIs per the external-services skill, and use a browser only when observing a
  rendered page or live runtime that no tool or API exposes. Every browser-harness task attaches to the
  user's normal Google Chrome through this skill's attach-chrome.sh script. Load before launching or
  attaching to any browser for web development, debugging, QA, scraping, or site automation.
---
# Browser tools

## Tool selection

A browser is never the way to retrieve content. Use one only to observe a rendered page or a live runtime that no
tool or API exposes. If an agent tool, an MCP server, or an API call can produce the answer, a browser is the wrong
choice whether it runs headless or visible. Resolve web tasks in this order.

1. For public pages, documentation, research, and web search, use the built-in search and fetch tools.
2. For content behind a login, use that service's MCP server, or its API with the credentials already in the environment. Follow the `external-services` skill. Never open a browser to sign in to a service whose token or key is already set.
3. Before launching a browser, name the observation that only the rendered page or the live runtime supplies: client-side rendering, layout, interaction, console output, network traffic, or a performance measurement. Search the available tools for a match first, including deferred tools reachable through `ToolSearch`. A browser that duplicates an existing tool or API is wasted work and added risk.
4. When a page needs the user's signed-in session and no MCP server or API credential covers the task, use `browser-harness` attached to the user's normal Google Chrome, as the "browser-harness execution" section describes. Never drive a sign-in screen or type a credential.
5. For web development, debugging, performance work, accessibility inspection, repeatable QA, DOM inspection, console and network analysis, Lighthouse, memory analysis, and browser emulation on pages that need no sign-in, use Chrome DevTools MCP. It manages its own Chrome instance. Run it headless unless a human must watch.
6. Use `browser-harness` for every task that needs the user's signed-in session, and for any task that needs a capability Chrome DevTools MCP does not provide or cannot complete: open-ended web operations requiring custom recovery, arbitrary Python or direct raw CDP, or custom or persistent site helpers.
7. State why before switching tools. Do not use fallback tooling to bypass authentication, authorization, or consent.
8. Validate browser work from rendered or runtime state with screenshots, DOM or accessibility reads, console or network evidence, or another direct observation appropriate to the task.
9. When Chrome DevTools MCP `take_screenshot` times out, capture with the command line instead: `google-chrome --headless=new --disable-gpu --force-color-profile=srgb --window-size=WxH --screenshot=out.png <url>`. Headless Chrome inherits the operating system's dark color scheme, so force the light theme in the page when a light capture is needed.

## Chrome requirement

Browser automation must use Google Chrome explicitly. Do not use Vivaldi, Firefox, Chromium, or another browser unless the user explicitly overrides this requirement for a named task.

## browser-harness execution

Every `browser-harness` task attaches to the user's normal Google Chrome profile (`~/.config/google-chrome`), which has remote debugging turned on at `chrome://inspect/#remote-debugging`. That profile holds the signed-in sessions and the password manager. Google refuses sign-in in a separate automated profile, so never launch Chrome with `--user-data-dir` or `--remote-debugging-port`.

`scripts/attach-chrome.sh` in this skill is the only supported way to connect. `install.sh` links it to `~/.local/bin/attach-chrome.sh`, so it is on `PATH`. The script launches Chrome when Chrome is not running, disables `browser-harness` telemetry, and starts a `browser-harness` daemon with a new name for this task. It connects that daemon to the port in `~/.config/google-chrome/DevToolsActivePort` and exits nonzero unless the daemon is connected to that port alone. It prints one line: `BU_NAME=<name> BU_CDP_WS=<url>`.

Follow this order.

1. Read the `browser-harness` skill.
2. Run `attach-chrome.sh` once at the start of the task, and save its output line to a file in the session scratchpad, for example `attach-chrome.sh > "$SCRATCHPAD/chrome.env"`. Shell variables do not survive between agent tool calls, and the file does.
3. If Chrome shows a remote-debugging approval dialog, ask the user to click Allow. If the script times out before the click, rerun it with the daemon name from the timed-out run, for example `attach-chrome.sh chrome-1792283478-1809768`.
4. If the script exits nonzero for any other reason, stop and report its message.
5. Prefix every `browser-harness` command in the task with the saved line, for example `env $(cat "$SCRATCHPAD/chrome.env") browser-harness <<'PY'`. Never run `browser-harness` without that prefix. Default discovery can attach to another browser on port 9222, and the default daemon can belong to another task.
6. Open each page with `new_tab(url)`, and reuse one tab per site for the rest of the task.
7. If a page shows a sign-in, passkey, MFA, or consent screen, stop and ask the user to complete it in Chrome.
8. If a `browser-harness` command fails in any way, run `browser-harness --doctor` with the same prefix as the very next command. Then rerun `attach-chrome.sh <name>` with the same name before any retry. Failures include a nonzero exit, a traceback, an import error, command not found, a connection error, a timeout, a hang, or unexpected daemon behavior.
9. Before `browser-harness --doctor` runs, do not debug, patch, reinstall, inspect wrappers, retry, or use `curl`, `WebFetch`, Playwright, or another browser.
10. At the end of the task, close the tabs that the task opened, unless the user needs to see one. Then stop the task's daemon with `BU_NAME=<name> browser-harness --reload`.

Each new daemon opens a new connection, and Chrome asks the user to approve every new connection. Expect one Allow click per task. A rerun of `attach-chrome.sh` with the same name reuses the connected daemon and asks for nothing.

Tasks that run at the same time share the one Chrome, but each task holds its own daemon and its own tabs. A task never stops another task's daemon and never acts in another task's tabs.
