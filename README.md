# AI Rules

Custom rules and commands for AI coding assistants including Claude Code, Cursor, and ChatGPT.

## Contents

### Global Rules
- **CLAUDE.md** - Global behavior, generation, and formatting rules for Claude Code. Applied automatically to all interactions.
  - Note: These settings can also be copy-pasted into the Cursor IDE in order to apply globally.
- **CHATGPT.md** - Concise rules for ChatGPT emphasizing direct, brief responses.

### Statusline
- **scripts/claude-statusline.js** - Claude Code `statusLine` command: model name, current directory, and a context-usage bar. `install.sh` links it to `~/.claude/statusline.js` and points `~/.claude/settings.json`'s `statusLine` key at it.

### Skills
- **skills/ask-questions/** - Systematic problem analysis and solution path optimization.
- **skills/code-review/** - Reviews changes between two branches with prioritized feedback.
- **skills/commit-push/** - Commits and pushes changes following Conventional Commits v1.0.0.
- **skills/feature-branch/** - Creates and checks out a Git feature branch from a Jira ticket.
- **skills/humanize/** - Audits writing for AI patterns; detect, rewrite, or edit modes.
- **skills/masticulate/** - Walks through an existing numbered list one item at a time.
- **skills/quiz/** - Builds a mnemonic recall scaffold and quizzes one prompt at a time.
- **skills/pull-request/** - Creates a PR with summary, test plan, and linked context.

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

# Symlink skills directory
ln -s ~/src/ai-rules/skills/ask-questions ~/.claude/skills/ask-questions
# Repeat for each skill, or run ./install.sh to link all skills at once.
```

After setup, Claude Code automatically loads `CLAUDE.md` into every conversation and discovers skills from `~/.claude/skills/*/SKILL.md`.

### Cursor

[Cursor](https://cursor.com/) uses a similar structure to Claude Code:
- **Global rules** are set in the IDE: `Cursor Settings > General > Rules for AI`
- **Project rules** go in `.cursor/rules/` within each project (`.mdc` format)
- **Skills** go in `~/.cursor/skills/` (personal) or `.cursor/skills/` within each project (`skill-name/SKILL.md` format)

To use these rules in Cursor:

1. **For global rules**: Open `Cursor Settings > General > Rules for AI` and paste the contents of `CLAUDE.md`

2. **For skills**: Run `./install.sh` from this repository, or symlink each skill directory into `~/.cursor/skills/`.

```bash
# Symlink all skills at once
./install.sh
```

After setup, Cursor discovers skills from `~/.cursor/skills/*/SKILL.md` and applies them when relevant.

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

