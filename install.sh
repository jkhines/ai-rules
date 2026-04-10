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

# ~/.claude.json (Claude Code application config)
link "$REPO_DIR/.claude.json" "$HOME/.claude.json"

# ~/.claude
link "$REPO_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
for file in "$REPO_DIR/commands/"*.md; do
    [ -e "$file" ] || continue
    link "$file" "$HOME/.claude/commands/$(basename "$file")"
done
for skill_dir in "$REPO_DIR/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    link "$skill_dir" "$HOME/.claude/skills/$skill_name"
done

# ~/.cursor
link "$REPO_DIR/mcp.json" "$HOME/.cursor/mcp.json"
for file in "$REPO_DIR/commands/"*.md; do
    [ -e "$file" ] || continue
    link "$file" "$HOME/.cursor/commands/$(basename "$file")"
done
for skill_dir in "$REPO_DIR/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    link "$skill_dir" "$HOME/.cursor/skills/$skill_name"
done

echo "Done."
