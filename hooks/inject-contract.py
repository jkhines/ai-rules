#!/usr/bin/env python3
"""UserPromptSubmit hook: restate the output contract at generation time.

CLAUDE.md loads once, at the top of the context window, where a long session buries it. This
hook appends the same rules in positive form to every prompt, so they sit next to the tokens
the model is about to generate. Pure standard library, so the hook needs no install step.
"""
import json
import sys
from pathlib import Path

CONTRACT = Path(__file__).resolve().parent / "output-contract.md"


def main():
    try:
        json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return
    try:
        text = CONTRACT.read_text().strip()
    except OSError:
        return  # A missing contract must never block the prompt.
    if not text:
        return
    print(json.dumps({
        "suppressOutput": True,
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": text,
        },
    }))


if __name__ == "__main__":
    main()
