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

create_opencode_skill_adapter() {
    local skill="$1"
    local dest="$2"
    local marker="<!-- Managed by ai-rules/install.sh; do not edit. -->"
    local tmp="${dest}.tmp"

    if ([ -e "$dest" ] || [ -L "$dest" ]) && ! grep -Fqx "$marker" "$dest"; then
        echo "WARN: $dest already exists and is not managed by this repository; skipping."
        return 0
    fi

    {
        printf '%s\n' '---'
        printf 'description: Run the %s skill workflow\n' "$skill"
        printf '%s\n\n' '---'
        printf '%s\n\n' "$marker"
        printf 'Load the `%s` skill using the skill tool, then follow it for this request:\n\n' "$skill"
        printf '%s\n' '$ARGUMENTS'
    } > "$tmp"

    if [ -f "$dest" ] && cmp -s "$tmp" "$dest"; then
        rm "$tmp"
        echo "OK: $dest already contains the $skill skill adapter"
        return 0
    fi

    mv "$tmp" "$dest"
    echo "Created OpenCode skill adapter: $dest"
}

# Ensure required scripts are executable in this clone.
chmod +x "$REPO_DIR/.githooks/pre-commit" "$REPO_DIR/install.sh" "$REPO_DIR/mcp.sh" "$REPO_DIR/setup.sh" "$REPO_DIR/scripts/open-google-chrome-cdp.sh" "$REPO_DIR/scripts/claude-statusline.js" "$REPO_DIR/hooks/inject-contract.py"

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

# Output-conformance hook: link the scripts, then register the one that shapes generation.
# CLAUDE.md loads once at the top of the context window, so a long session buries it, and
# UserPromptSubmit restates the contract next to the tokens being generated.
#
# No Stop hook and no MessageDisplay hook. A Stop hook can only block a finished turn, which makes
# the model send a second message, and a MessageDisplay hook can only add a note under the reply.
# The first message has to be right instead, so UserPromptSubmit is the only registration here.
HOOKS_DIR="$HOME/.claude/hooks"
mkdir -p "$HOOKS_DIR"
cleanup_repo_symlinks "$HOOKS_DIR"
for hook in inject-contract.py output-contract.md; do
    link "$REPO_DIR/hooks/$hook" "$HOOKS_DIR/$hook"
done

INJECT_CMD="python3 \"$HOOKS_DIR/inject-contract.py\""

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if command -v jq >/dev/null 2>&1; then
    [ -f "$CLAUDE_SETTINGS" ] || echo '{}' > "$CLAUDE_SETTINGS"
    jq --arg cmd "node \"$STATUSLINE_LINK\"" \
        --arg inject "$INJECT_CMD" \
        '
        # Drop any earlier registration of the same command so reruns do not stack duplicates.
        def prune($cmd): map(select([.hooks[]?.command] | index($cmd) | not));
        .statusLine = {"type": "command", "command": $cmd}
        | .hooks //= {}
        | .hooks.UserPromptSubmit = ((.hooks.UserPromptSubmit // []) | prune($inject))
            + [{"hooks": [{"type": "command", "command": $inject, "timeout": 5}]}]
        ' \
        "$CLAUDE_SETTINGS" > "${CLAUDE_SETTINGS}.tmp"
    mv "${CLAUDE_SETTINGS}.tmp" "$CLAUDE_SETTINGS"
    echo "Configured statusLine in $CLAUDE_SETTINGS -> $STATUSLINE_LINK"
    echo "Registered the UserPromptSubmit hook in $CLAUDE_SETTINGS"
else
    echo "WARN: jq not found; skipping statusLine and hook configuration in $CLAUDE_SETTINGS"
fi

# ~/.cursor
mkdir -p "$HOME/.cursor/skills"
cleanup_repo_symlinks "$HOME/.cursor/skills"
link "$REPO_DIR/.cursor.mcp.json" "$HOME/.cursor/mcp.json"
for dir in "$REPO_DIR/skills/"*/; do
    [ -e "$dir" ] || continue
    link "$dir" "$HOME/.cursor/skills/$(basename "$dir")"
done

# ~/.config/opencode
# OpenCode reads its global rules from AGENTS.md in this directory, and it already auto-loads every
# skill in ~/.claude/skills, so the skills linked above need no second link here.
OPENCODE_DIR="$HOME/.config/opencode"
mkdir -p "$OPENCODE_DIR"
link "$REPO_DIR/CLAUDE.md" "$OPENCODE_DIR/AGENTS.md"

# opencode.json holds user settings such as providers and permissions next to the MCP servers, so
# merge the managed keys instead of replacing the whole file.
#
# OpenCode reaches OpenRouter through the OPENROUTER_API_KEY environment variable, so the provider
# needs no entry here. Only the default model does.
OPENCODE_CONFIG="$OPENCODE_DIR/opencode.json"
OPENCODE_MODEL="openrouter/openai/gpt-5.6-sol"
if command -v jq >/dev/null 2>&1; then
    [ -f "$OPENCODE_CONFIG" ] || echo '{}' > "$OPENCODE_CONFIG"
    jq --slurpfile generated "$REPO_DIR/.opencode.mcp.json" --arg model "$OPENCODE_MODEL" \
        '.["$schema"] = $generated[0]["$schema"] | .model = $model | .mcp = $generated[0].mcp' \
        "$OPENCODE_CONFIG" > "${OPENCODE_CONFIG}.tmp"
    mv "${OPENCODE_CONFIG}.tmp" "$OPENCODE_CONFIG"
    echo "Set model $OPENCODE_MODEL and merged MCP servers into $OPENCODE_CONFIG"
else
    echo "WARN: jq not found; skipping model and MCP configuration in $OPENCODE_CONFIG"
fi

# OpenCode discovers the linked skills above but does not register each skill as a custom command.
# Add thin command adapters so every repository skill is also available as /<skill-name>.
OPENCODE_COMMANDS_DIR="$OPENCODE_DIR/commands"
mkdir -p "$OPENCODE_COMMANDS_DIR"
for dir in "$REPO_DIR/skills/"*/; do
    [ -e "$dir" ] || continue
    skill="$(basename "$dir")"
    create_opencode_skill_adapter "$skill" "$OPENCODE_COMMANDS_DIR/$skill.md"
done

# ~/.local/bin
link "$REPO_DIR/scripts/open-google-chrome-cdp.sh" "$HOME/.local/bin/open-google-chrome-cdp.sh"

echo "Done."
