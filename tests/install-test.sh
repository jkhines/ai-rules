#!/usr/bin/env bash
# Runs install.sh against a copy of this repository and a temporary HOME, then checks what it installed.
# The copy keeps the real ~/.claude.json, which links into this repository, out of reach.
set -euo pipefail
unset MCP_EXTRA_SOURCES SKILL_EXTRA_DIRS

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
FAILURES=0

fail() {
    echo "FAIL: $1"
    FAILURES=$((FAILURES + 1))
}

# Copy the repository without .git, so install.sh skips the git hook configuration.
fresh_repo() {
    rm -rf "$WORK/ai-rules" "$WORK/home"
    mkdir -p "$WORK/ai-rules" "$WORK/home"
    tar -C "$SOURCE_DIR" --exclude=.git -cf - . | tar -C "$WORK/ai-rules" -xf -
}

install() {
    HOME="$WORK/home" "$WORK/ai-rules/install.sh" >"$WORK/install.log" 2>&1 || {
        cat "$WORK/install.log"
        fail "install.sh exited with an error"
    }
}

test_public_mcp_servers_include_microsoft_365() {
    fresh_repo
    install
    for config in "$WORK/home/.claude.json" "$WORK/home/.cursor/mcp.json"; do
        [ "$(jq -r '.mcpServers["Microsoft 365"].url' "$config")" = "https://microsoft365.mcp.claude.com/mcp" ] ||
            fail "Microsoft 365 is missing from $config"
    done
    [ "$(jq -r '.mcp["Microsoft 365"].url' "$WORK/home/.config/opencode/opencode.json")" = "https://microsoft365.mcp.claude.com/mcp" ] ||
        fail "Microsoft 365 is missing from opencode.json"
}

test_extra_skill_dirs_are_installed() {
    fresh_repo
    mkdir -p "$WORK/extra/extra-skill"
    echo "extra" > "$WORK/extra/extra-skill/SKILL.md"
    SKILL_EXTRA_DIRS="$WORK/extra" install
    for dest in "$WORK/home/.claude/skills/extra-skill" "$WORK/home/.cursor/skills/extra-skill"; do
        [ "$(readlink "$dest")" = "$WORK/extra/extra-skill/" ] || fail "$dest does not link to the extra skill"
    done
    grep -q 'Load the `extra-skill` skill' "$WORK/home/.config/opencode/commands/extra-skill.md" 2>/dev/null ||
        fail "the OpenCode adapter for the extra skill is missing"
}

test_deleted_extra_skill_is_removed() {
    fresh_repo
    mkdir -p "$WORK/extra/extra-skill"
    echo "extra" > "$WORK/extra/extra-skill/SKILL.md"
    SKILL_EXTRA_DIRS="$WORK/extra" install
    rm -rf "$WORK/extra/extra-skill"
    SKILL_EXTRA_DIRS="$WORK/extra" install
    for dest in "$WORK/home/.claude/skills/extra-skill" "$WORK/home/.cursor/skills/extra-skill" \
        "$WORK/home/.config/opencode/commands/extra-skill.md"; do
        { [ -e "$dest" ] || [ -L "$dest" ]; } && fail "$dest remains after its skill was deleted"
    done
    [ -L "$WORK/home/.claude/skills/humanize" ] || fail "a repository skill link is missing after the rerun"
}

test_public_mcp_servers_include_microsoft_365
test_extra_skill_dirs_are_installed
test_deleted_extra_skill_is_removed

if [ "$FAILURES" -gt 0 ]; then
    echo "$FAILURES failure(s)."
    exit 1
fi
echo "All install tests passed."
