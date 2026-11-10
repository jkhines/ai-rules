#!/usr/bin/env bash
# Attach a browser-harness daemon to the user's normal Google Chrome profile and print its command prefix.
#
# Usage: attach-chrome.sh [daemon-name]
#
# Each task uses its own named daemon, so this script never stops a daemon that another task holds.
# Pass the name printed by an earlier run to reconnect the same task after Chrome restarts.
# browser-harness default discovery falls back to port 9222, where another Chromium browser can listen, so never rely on it.
set -euo pipefail

name="${1:-chrome-$(date +%s)-$$}"
if [[ ! "$name" =~ ^[A-Za-z0-9_-]{1,64}$ ]]; then
  printf 'Invalid daemon name: %s\n' "$name" >&2
  exit 2
fi
if [[ -n "${BH_RUNTIME_DIR:-}" ]]; then
  printf 'Unset BH_RUNTIME_DIR. It gives every named daemon the same pid file.\n' >&2
  exit 2
fi

# A run that times out while Chrome waits for the user's approval must be rerun with the same name.
trap 'status=$?; [[ $status -eq 0 ]] || printf "To retry this task'"'"'s daemon, run: attach-chrome.sh %s\n" "$name" >&2' EXIT

active_port_file="$HOME/.config/google-chrome/DevToolsActivePort"
pid_file="$HOME/.config/browser-harness/runtime/bu-${name}.pid"

chrome_owns_port() {
  ss -tlnpH "sport = :$1" 2>/dev/null | grep -q '(("chrome",'
}

live_port() {
  [[ -r "$active_port_file" ]] || return 1
  local port
  port="$(sed -n 1p "$active_port_file")"
  [[ -n "$port" ]] && chrome_owns_port "$port" && printf '%s\n' "$port"
}

# Print the remote port of every established connection that this task's daemon holds.
daemon_peer_ports() {
  local pid
  [[ -r "$pid_file" ]] || return 0
  pid="$(cat "$pid_file")"
  ss -tnpH state established 2>/dev/null | awk -v tag="pid=${pid}," 'index($0, tag) { n = split($4, a, ":"); print a[n] }'
}

connected_only_to() {
  local ports
  ports="$(daemon_peer_ports | sort -u)"
  [[ "$ports" == "$1" ]]
}

if browser-harness telemetry status 2>/dev/null | grep -q '"enabled": true'; then
  browser-harness telemetry disable >/dev/null
fi

if ! live_port >/dev/null; then
  setsid google-chrome >/dev/null 2>&1 &
  for _ in $(seq 1 100); do
    live_port >/dev/null && break
    sleep 0.2
  done
fi

port="$(live_port)" || {
  printf 'Google Chrome is not listening on the port in %s. Enable chrome://inspect/#remote-debugging in Google Chrome.\n' "$active_port_file" >&2
  exit 1
}
ws="ws://127.0.0.1:${port}$(sed -n 2p "$active_port_file")"

# A running daemon keeps its old connection, so restart this task's daemon when Chrome's port changed.
if ! connected_only_to "$port"; then
  BU_NAME="$name" browser-harness --reload >/dev/null 2>&1 || true
fi
BU_NAME="$name" BU_CDP_WS="$ws" browser-harness <<<'cdp("Browser.getVersion")' >/dev/null

# Vivaldi also reports a Chrome/ product string, so check the daemon's socket instead.
if ! connected_only_to "$port"; then
  printf 'The browser-harness daemon %s is not connected only to Google Chrome on port %s.\n' "$name" "$port" >&2
  exit 1
fi

printf 'BU_NAME=%s BU_CDP_WS=%s\n' "$name" "$ws"
