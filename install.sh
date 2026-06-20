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

# Sync MCP servers from mcp.json into .claude.json
"$REPO_DIR/mcp.sh"

# Ensure required scripts are executable in this clone.
chmod +x "$REPO_DIR/.githooks/pre-commit" "$REPO_DIR/install.sh" "$REPO_DIR/mcp.sh" "$REPO_DIR/setup.sh"

# Ensure repository hooks are active for this clone.
if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_DIR" config core.hooksPath .githooks
    echo "Configured git hooks path: .githooks"
fi

# ~/.claude.json (Claude Code application config)
link "$REPO_DIR/.claude.json" "$HOME/.claude.json"

# ~/.claude
link "$REPO_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
for file in "$REPO_DIR/commands/"*.md; do
    [ -e "$file" ] || continue
    link "$file" "$HOME/.claude/commands/$(basename "$file")"
done

# ~/.cursor
link "$REPO_DIR/mcp.json" "$HOME/.cursor/mcp.json"
for file in "$REPO_DIR/commands/"*.md; do
    [ -e "$file" ] || continue
    link "$file" "$HOME/.cursor/commands/$(basename "$file")"
done

echo "Done."
