---
name: explicit-gemini
description: Rewrites text against the Explicit rules using Gemini 3.1 Pro, without switching the model of this conversation.
---

# Explicit Gemini

Rewrite text against the rules in the `explicit-inline` skill, using Gemini 3.1 Pro through `cursor-agent`.

Do not rewrite the text yourself. The `cursor-agent` call bills the Cursor plan and starts a fresh session, so this conversation is never re-sent and a long session costs no more than a short one.

Write the text to a file, then run:

```bash
IN="$(mktemp)"; WS="$(mktemp -d)"
cat > "$IN" <<'TEXT'
Paste the text to rewrite here, unchanged.
TEXT
S="$HOME/.claude/skills/explicit-inline/SKILL.md"
[ -f "$S" ] || S="$HOME/.cursor/skills/explicit-inline/SKILL.md"
[ -f "$S" ] || { echo "explicit-inline skill not found; run install.sh" >&2; exit 1; }
cursor-agent -p --model gemini-3.1-pro --mode ask --output-format text --workspace "$WS" \
  "$(printf 'Rewrite the text below so it follows every rule in the instructions. Return only the rewritten text, with no preamble and no commentary.\n\n<instructions>\n%s\n</instructions>\n\n<text>\n%s\n</text>\n' \
     "$(cat "$S")" "$(cat "$IN")")"
rm -rf "$WS" "$IN"
```

Return the command output verbatim. Never edit it.
