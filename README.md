# AI Rules for Cursor

This repository contains custom rules for Cursor IDE in `.mdc` format. These rules define how the AI assistant behaves when working in Cursor.

## Files

- **rules-agent-ask-questions.mdc** - Command `/ask-questions`: Systematic problem analysis and solution path optimization.
- **rules-agent-code-review.mdc** - Command `/code-review`: Reviews two branches and provides comprehensive feedback.
- **rules-agent-general.mdc** - Global formatting and behavior rules that always apply to agent interactions
- **rules-agent-memory-bank.mdc** - Command `/memory-bank`: Bases all actions on context files from a memory bank system based on [https://docs.cline.bot/prompting/cline-memory-bank](https://docs.cline.bot/prompting/cline-memory-bank).
- **rules-agent-write-summary.mdc** - Command `/write-summary`: Writes conversation summary to disk for future context.
- **rules-chat-general.mdc** - General chat behavior rules for plain, direct communication style.

## License

This work is dedicated to the public domain under CC0 1.0 Universal.

