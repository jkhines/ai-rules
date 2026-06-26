#!/usr/bin/env bash
# Merges mcpServers from mcp.json (Cursor format) into .claude.json (Claude Code format).
# Run this after editing mcp.json to sync MCP servers into Claude Code's config.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_FILE="$REPO_DIR/mcp.json"
CLAUDE_FILE="$REPO_DIR/.claude.json"

if [ ! -f "$MCP_FILE" ]; then
    echo "ERROR: $MCP_FILE not found"
    exit 1
fi

# Start from this repo's public servers, then merge any extra source files named in the
# MCP_EXTRA_SOURCES environment variable (colon-separated absolute paths). Those files hold
# internal-only servers that must stay out of this public repo; later sources win on collisions.
SOURCES=("$MCP_FILE")
if [ -n "${MCP_EXTRA_SOURCES:-}" ]; then
    IFS=':' read -ra EXTRA <<< "$MCP_EXTRA_SOURCES"
    for f in "${EXTRA[@]}"; do
        [ -n "$f" ] || continue
        if [ -f "$f" ]; then
            echo "Merging MCP servers from $f"
            SOURCES+=("$f")
        else
            echo "WARN: MCP_EXTRA_SOURCES entry not found: $f"
        fi
    done
fi

# Convert Cursor format to Claude Code format: add "type": "http" to URL-based servers.
CONVERT='map_values(if has("url") and (has("type") | not) then . + {"type": "http"} else . end)'

# Reduce all sources left-to-right so later (sibling) entries override earlier (public) ones.
MCP_SERVERS=$(jq -s "(reduce .[] as \$s ({}; . + (\$s.mcpServers // {}))) | $CONVERT" "${SOURCES[@]}")

if [ -f "$CLAUDE_FILE" ]; then
    jq --argjson servers "$MCP_SERVERS" '.mcpServers = $servers' "$CLAUDE_FILE" > "${CLAUDE_FILE}.tmp"
    mv "${CLAUDE_FILE}.tmp" "$CLAUDE_FILE"
else
    jq -n --argjson servers "$MCP_SERVERS" '{"mcpServers": $servers}' > "$CLAUDE_FILE"
fi

echo "Updated $CLAUDE_FILE with MCP servers from $MCP_FILE"
