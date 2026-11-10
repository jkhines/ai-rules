#!/usr/bin/env python3
"""UserPromptSubmit hook: restate the output contract at generation time.

AGENTS.md (linked to ~/.claude/CLAUDE.md) loads once, at the top of the context window, where a long
session buries it. This hook appends the same rules in positive form to every prompt, so they sit next
to the tokens the model is about to generate. Pure standard library, so the hook needs no install step.

Claude Code replaces any additionalContext string over 10,000 characters with a file path and a
2,000-character preview, and it measures each hook's string on its own. The contract is therefore
written as two <output_contract> blocks, and settings.json registers this script twice, once per
block: `inject-contract.py 1` and `inject-contract.py 2`. Each block must stay under the cap.
"""
import json
import re
import sys
from pathlib import Path

CONTRACT = Path(__file__).resolve().parent / "output-contract.md"
CAP = 10_000
BLOCK = re.compile(r"<output_contract\b.*?</output_contract>", re.S)


def main():
    try:
        json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return
    part = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    try:
        blocks = BLOCK.findall(CONTRACT.read_text())
    except OSError:
        return  # A missing contract must never block the prompt.
    if part < 1 or part > len(blocks):
        return
    text = blocks[part - 1].strip()
    if len(text) > CAP:
        print(f"output-contract.md block {part} is {len(text)} characters; Claude Code truncates it above {CAP}.", file=sys.stderr)
    print(json.dumps({
        "suppressOutput": True,
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": text,
        },
    }))


if __name__ == "__main__":
    main()
