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

# Convert Cursor format to Claude Code format: add "type": "http" to URL-based servers.
MCP_SERVERS=$(jq '(.mcpServers // {}) | map_values(if has("url") and (has("type") | not) then . + {"type": "http"} else . end)' "$MCP_FILE")

if [ -f "$CLAUDE_FILE" ]; then
    jq --argjson servers "$MCP_SERVERS" '.mcpServers = $servers' "$CLAUDE_FILE" > "${CLAUDE_FILE}.tmp"
    mv "${CLAUDE_FILE}.tmp" "$CLAUDE_FILE"
else
    jq -n --argjson servers "$MCP_SERVERS" '{"mcpServers": $servers}' > "$CLAUDE_FILE"
fi

echo "Updated $CLAUDE_FILE with MCP servers from $MCP_FILE"
