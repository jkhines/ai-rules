#!/usr/bin/env bash
set -euo pipefail

url="${1:-https://www.ibm.com}"
port="${CHROME_REMOTE_DEBUGGING_PORT:-9222}"
profile_dir="${CHROME_USER_DATA_DIR:-${XDG_RUNTIME_DIR:-/tmp}/cursor-google-chrome-cdp-profile}"
log_file="${CHROME_LAUNCH_LOG:-${XDG_RUNTIME_DIR:-/tmp}/cursor-google-chrome-cdp.log}"

find_chrome() {
  if [[ -x /usr/bin/google-chrome ]]; then
    printf '%s\n' /usr/bin/google-chrome
    return 0
  fi

  if command -v google-chrome-stable >/dev/null 2>&1; then
    command -v google-chrome-stable
    return 0
  fi

  if command -v google-chrome >/dev/null 2>&1; then
    command -v google-chrome
    return 0
  fi

  return 1
}

chrome_bin="$(find_chrome)" || {
  printf 'Google Chrome was not found. Expected /usr/bin/google-chrome or google-chrome on PATH.\n' >&2
  exit 1
}

chrome_realpath="$(readlink -f "$chrome_bin")"
case "$chrome_realpath" in
  */google-chrome|*/google-chrome-stable|*/chrome)
    ;;
  *)
    printf 'Refusing non-Google-Chrome binary: %s -> %s\n' "$chrome_bin" "$chrome_realpath" >&2
    exit 1
    ;;
esac

if python3 - "$port" <<'PY' >/dev/null 2>&1
import sys
import urllib.request

port = sys.argv[1]
urllib.request.urlopen(f"http://127.0.0.1:{port}/json/version", timeout=0.25).read()
PY
then
  printf 'Port %s already has a DevTools endpoint. Set CHROME_REMOTE_DEBUGGING_PORT to a free port.\n' "$port" >&2
  exit 1
fi

mkdir -p "$profile_dir"
: >"$log_file"

"$chrome_bin" \
  --new-window \
  --no-first-run \
  --no-default-browser-check \
  --disable-features=Vulkan \
  --remote-debugging-port="$port" \
  --user-data-dir="$profile_dir" \
  "$url" >"$log_file" 2>&1 &

launcher_pid="$!"

set +e
ws_url="$(
  python3 - "$port" <<'PY'
import json
import sys
import time
import urllib.request

port = sys.argv[1]
last_error = None

for _ in range(100):
    try:
        with urllib.request.urlopen(f"http://127.0.0.1:{port}/json/version", timeout=0.25) as response:
            version = json.load(response)
        print(version["webSocketDebuggerUrl"])
        raise SystemExit(0)
    except Exception as exc:
        last_error = exc
        time.sleep(0.1)

print(f"DevTools endpoint did not become ready: {last_error}", file=sys.stderr)
raise SystemExit(1)
PY
)"
status="$?"
set -e

if [[ "$status" -ne 0 ]]; then
  printf 'Google Chrome launch failed. Launcher PID: %s. Log: %s\n' "$launcher_pid" "$log_file" >&2
  exit "$status"
fi

if ! ps -eo args= | awk -v port="$port" '
  /\/opt\/google\/chrome|\/usr\/bin\/google-chrome|google-chrome/ && index($0, "--remote-debugging-port=" port) {
    found = 1
  }
  END { exit found ? 0 : 1 }
'; then
  printf 'DevTools is ready, but no matching Google Chrome process was found for port %s.\n' "$port" >&2
  printf 'Log: %s\n' "$log_file" >&2
  exit 1
fi

printf 'Opened %s in Google Chrome.\n' "$url"
printf 'BU_CDP_WS=%s\n' "$ws_url"
