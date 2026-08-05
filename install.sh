#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"

    # No-op when destination already points to the intended source.
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "OK: $dest already -> $src"
        return 0
    fi

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        # Create a single backup copy and avoid cascading backups on reruns.
        if [ ! -e "${dest}.bak" ]; then
            echo "Backing up existing $dest to ${dest}.bak"
            mv "$dest" "${dest}.bak"
        else
            echo "WARN: $dest exists and ${dest}.bak already exists; skipping."
            return 0
        fi
    fi
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
}

# Remove symlinks previously installed from this repository (including stale names/layouts).
cleanup_repo_symlinks() {
    local dir="$1"
    local entry target

    [ -d "$dir" ] || return 0

    for entry in "$dir"/*; do
        [ -e "$entry" ] || [ -L "$entry" ] || continue
        [ -L "$entry" ] || continue

        target="$(readlink "$entry")"
        case "$target" in
            "$REPO_DIR"/*)
                rm "$entry"
                echo "Removed stale link: $entry"
                ;;
        esac
    done
}

# Ensure required scripts are executable in this clone.
chmod +x "$REPO_DIR/.githooks/pre-commit" "$REPO_DIR/install.sh" "$REPO_DIR/mcp.sh" "$REPO_DIR/setup.sh" "$REPO_DIR/scripts/open-google-chrome-cdp.sh" "$REPO_DIR/scripts/claude-statusline.js"

# Sync MCP servers from mcp.json into generated app configs.
"$REPO_DIR/mcp.sh"

# Ensure repository hooks are active for this clone.
if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_DIR" config core.hooksPath .githooks
    echo "Configured git hooks path: .githooks"
fi

# ~/.claude.json (Claude Code application config)
link "$REPO_DIR/.claude.json" "$HOME/.claude.json"

# ~/.claude
mkdir -p "$HOME/.claude/skills"
cleanup_repo_symlinks "$HOME/.claude/skills"
link "$REPO_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
for dir in "$REPO_DIR/skills/"*/; do
    [ -e "$dir" ] || continue
    link "$dir" "$HOME/.claude/skills/$(basename "$dir")"
done

# Statusline: link the script, then point Claude Code's statusLine setting at
# it via a jq merge so the rest of ~/.claude/settings.json (hooks, model, etc.)
# is left untouched.
STATUSLINE_LINK="$HOME/.claude/statusline.js"
link "$REPO_DIR/scripts/claude-statusline.js" "$STATUSLINE_LINK"

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if command -v jq >/dev/null 2>&1; then
    [ -f "$CLAUDE_SETTINGS" ] || echo '{}' > "$CLAUDE_SETTINGS"
    jq --arg cmd "node \"$STATUSLINE_LINK\"" \
        '.statusLine = {"type": "command", "command": $cmd}' \
        "$CLAUDE_SETTINGS" > "${CLAUDE_SETTINGS}.tmp"
    mv "${CLAUDE_SETTINGS}.tmp" "$CLAUDE_SETTINGS"
    echo "Configured statusLine in $CLAUDE_SETTINGS -> $STATUSLINE_LINK"
else
    echo "WARN: jq not found; skipping statusLine configuration in $CLAUDE_SETTINGS"
fi

# ~/.cursor
mkdir -p "$HOME/.cursor/skills"
cleanup_repo_symlinks "$HOME/.cursor/skills"
link "$REPO_DIR/.cursor.mcp.json" "$HOME/.cursor/mcp.json"
for dir in "$REPO_DIR/skills/"*/; do
    [ -e "$dir" ] || continue
    link "$dir" "$HOME/.cursor/skills/$(basename "$dir")"
done

# ~/.local/bin
link "$REPO_DIR/scripts/open-google-chrome-cdp.sh" "$HOME/.local/bin/open-google-chrome-cdp.sh"

echo "Done."
