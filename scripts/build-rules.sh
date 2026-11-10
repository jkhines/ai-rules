#!/usr/bin/env bash
# Write the global rules file that Claude Code and OpenCode read: this repository's AGENTS.md, followed by
# every Markdown file in the local append directory. Another repository can add rules on this machine by
# linking a file into that directory, so its content never enters this repository.
#
# The output is a read-only copy, not a link, and holds only the rules text. An agent that tries to
# edit the global rules file fails instead of writing through a link into this repository.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPEND_DIR="${AGENT_RULES_APPEND_DIR:-$HOME/.config/agent-rules/append.d}"
TARGETS=("$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md")

mkdir -p "$APPEND_DIR"

compose() {
    cat "$REPO_DIR/AGENTS.md"
    for file in "$APPEND_DIR"/*.md; do
        [ -e "$file" ] || continue
        printf '\n'
        cat "$file"
    done
}

composed="$(mktemp)"
trap 'rm -f "$composed"' EXIT
compose > "$composed"

for dest in "${TARGETS[@]}"; do
    mkdir -p "$(dirname "$dest")"
    # Keep one backup of a hand-written file. A link or an earlier generated copy, which is read-only, is
    # replaced silently.
    if [ -f "$dest" ] && [ ! -L "$dest" ] && [ -w "$dest" ]; then
        if [ -e "${dest}.bak" ]; then
            echo "WARN: $dest is not a generated copy and ${dest}.bak already exists; skipping."
            continue
        fi
        echo "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    cp "$composed" "${dest}.tmp"
    chmod 444 "${dest}.tmp"
    mv -f "${dest}.tmp" "$dest"
    echo "Wrote $dest"
done
