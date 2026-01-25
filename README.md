# AI Rules

Custom rules and commands for AI coding assistants including Claude Code, Cursor, and ChatGPT.

## Contents

### Global Rules
- **CLAUDE.md** - Global behavior, generation, and formatting rules for Claude Code. Applied automatically to all interactions.
  - Note: These settings can also be copy-pasted into the Cursor IDE in order to apply globally.
- **CHATGPT.md** - Concise rules for ChatGPT emphasizing direct, brief responses.

### Commands
- **commands/ask-questions.md** - `/ask-questions`: Systematic problem analysis and solution path optimization.
- **commands/code-review.md** - `/code-review`: Reviews changes between two branches with prioritized feedback.
- **commands/commit-push.md** - `/commit-push`: Commits and pushes changes following Conventional Commits v1.0.0.

---

## Setup Instructions

### Claude Code

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) reads configuration from the `~/.claude/` directory. Use symlinks to keep rules synced with this repository.

```bash
# Clone the repository
git clone https://github.com/jkhines/ai-rules.git ~/src/ai-rules

# Create the Claude config directory if it doesn't exist
mkdir -p ~/.claude

# Symlink global rules
ln -s ~/src/ai-rules/CLAUDE.md ~/.claude/CLAUDE.md

# Symlink commands directory
ln -s ~/src/ai-rules/commands ~/.claude/commands
```

After setup, Claude Code automatically loads `CLAUDE.md` into every conversation and makes commands available via `/ask-questions`, `/code-review`, and `/commit-push`.

### Cursor

[Cursor](https://cursor.com/) uses a similar structure to Claude Code:
- **Global rules** are set in the IDE: `Cursor Settings > General > Rules for AI`
- **Project rules** go in `.cursor/rules/` within each project (`.mdc` format)
- **Slash commands** go in `.cursor/commands/` within each project (`.md` format)

To use these rules in Cursor:

1. **For global rules**: Open `Cursor Settings > General > Rules for AI` and paste the contents of `CLAUDE.md`

2. **For slash commands**: If the ~/.cursor/commands symlink has been set, slash commands will be imported into the Cursor IDE and cursor-agent.

```bash
# Symlink commands for slash command support (/ask-questions, /code-review, /commit-push)
ln -s ~/src/ai-rules/commands ~/.cursor/commands
```

After setup, invoke commands in Cursor's chat with `/ask-questions`, `/code-review`, or `/commit-push`.

### ChatGPT

[ChatGPT](https://chat.openai.com/) does not support file-based configuration. Instead, copy rules into the Custom Instructions setting:

1. Open ChatGPT and go to `Settings > Personalization > Customize ChatGPT`
2. Ensure "Enable customization" is toggled ON
3. Paste the contents of `CHATGPT.md` into the Custom Instructions field
4. Instructions apply to all new conversations (1,500 character limit)

---

## Keeping Rules Updated

With symlinks, pulling updates from this repository automatically updates your Claude Code and Cursor configurations:

```bash
cd ~/src/ai-rules
git pull
```

---

## License

This work is dedicated to the public domain under CC0 1.0 Universal.

