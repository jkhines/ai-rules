# AI Rules

Custom rules and commands for AI coding assistants including Claude Code, Cursor, and ChatGPT.

## Contents

### Global Rules
- **CLAUDE.md** - Global behavior, generation, and formatting rules for Claude Code. Applied automatically to all interactions.
  - Note: These settings can also be copy-pasted into the Cursor IDE in order to apply globally.
- **CHATGPT.md** - Concise rules for ChatGPT emphasizing direct, brief responses.

### Statusline
- **scripts/claude-statusline.js** - Claude Code `statusLine` command: model name, current directory, and a context-usage bar. `install.sh` links it to `~/.claude/statusline.js` and points `~/.claude/settings.json`'s `statusLine` key at it.

### Output-conformance hooks

`CLAUDE.md` loads once, at the top of the context window, so a long session buries it and the model drifts back to preambles, em dashes, and flagged vocabulary. These hooks close that gap without asking you anything. `install.sh` links all four files into `~/.claude/hooks/` and registers the first two in `~/.claude/settings.json`.

- **hooks/output-contract.md** - the `CLAUDE.md` output rules that fail most often, restated in positive form with three before-and-after examples. `CLAUDE.md` stays the source of truth.
- **hooks/inject-contract.py** - `UserPromptSubmit` hook. Appends the contract to every prompt as `additionalContext`, so the rules sit beside the tokens the model is about to write instead of thousands of tokens above them.
- **hooks/prose-check.py** - `Stop` hook. Reads the model's own last message from the session transcript and checks the rules a program can decide. A failure returns `decision: block` with the specific violations, so the model rewrites the message itself. Two rewrites at most, then the turn passes, so a bad rule cannot trap the session.
- **hooks/test-prose-check.py** - fixtures for the checker, run with `python3 hooks/test-prose-check.py`. The negative fixtures matter more than the positive ones, because a false positive forces a rewrite the writer cannot satisfy.
- **hooks/prose-annotate.py** - `MessageDisplay` hook, linked but not registered. Appends the softer findings as one grey line under the message. Add it to `~/.claude/settings.json` under `MessageDisplay` if you want them on screen.

`prose-check.py` blocks on sentences over 25 words, em dashes, emoji, chatbot tics, filler transitions, and the Tier 1 and words-to-avoid entries in `skills/humanize/SKILL.md`. It also blocks on the three failures that hurt readers most:

- **sentence fragments**, found with a verb lexicon rather than a part-of-speech tagger. The rules trade recall for precision, since a false positive forces a rewrite and a miss costs only a fragment.
- **analogies and similes**, matched on `like a`, `as if`, `think of it as`, `akin to`, `is essentially a`, and their relatives. The message tells the model to name the mechanism instead.
- **dense prose**, measured three ways: nouns built from verbs above 6% of the words, runs of five content words with no function word between them, and an estimated Flesch-Kincaid grade above 12 once the text passes 60 words.

Everything else comes back as a note rather than a block. That covers paragraph length, negative parallelism, `Label: value` notes, hedges, Tier 2 clusters, Tier 3 density, and a grade above 10.

Backticks and block quotations are the escape hatch. `prose-check.py` skips fenced code, inline code spans, tables, headings, and quoted lines, so a technical artifact or someone else's words pass untouched. Words in the humanize tables carrying a parenthetical condition, such as `deploy (unless military or software)`, warn rather than block, because no program can decide the exception.

Vocabulary is read live from `skills/humanize/SKILL.md`, so editing the skill changes what the hook enforces. The scripts use only the Python standard library.

### Skills
- **skills/agent-instructions/** - The AGENTS.md open standard for portable AI agent instructions.
- **skills/ask-questions/** - Systematic problem analysis and solution path optimization.
- **skills/browser-tools/** - Browser tool selection, Chrome isolation, and browser-harness execution.
- **skills/code-review/** - Reviews changes between two branches with prioritized feedback.
- **skills/commit-push/** - Commits and pushes changes following Conventional Commits v1.0.0.
- **skills/external-services/** - Credentials, environment variables, and API conventions for third-party services.
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

