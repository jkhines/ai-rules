#!/usr/bin/env python3
"""MessageDisplay hook: append a one-line prose note under Claude's message. Opt-in.

MessageDisplay is read-only. It cannot block or force a rewrite, so it complements prose-check.py
rather than replacing it: it reports the softer signals that prose-check lets through. It receives
the message text directly on stdin, so there is no transcript race, and it costs one appended
line rather than a second message.

install.sh does not register this hook. Add it to ~/.claude/settings.json under MessageDisplay
when you want the notes on screen.
"""
import importlib.util
import json
import sys
from pathlib import Path

CHECKER = Path(__file__).resolve().parent / "prose-check.py"


def load_checks():
    spec = importlib.util.spec_from_file_location("prose_check", CHECKER)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return
    if not payload.get("is_final"):
        return  # Fires on every streaming chunk otherwise.
    text = payload.get("message_text") or ""
    if not text.strip():
        return

    try:
        _, warnings = load_checks().run_checks(text)
    except Exception:
        return  # A broken checker must never mangle the display.

    findings = [w for w in warnings if not w.startswith("stats:")]
    if not findings:
        return

    note = "  ".join(f.split(":")[0].strip() for f in findings[:4])
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "MessageDisplay",
            "displayContent": f"{text}\n\n`prose: {note}`",
        }
    }))


if __name__ == "__main__":
    main()
