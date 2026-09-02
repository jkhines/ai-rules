# AI Rules

Custom rules and commands for AI coding assistants including Claude Code, Cursor, OpenCode, and ChatGPT.

## Contents

### Global Rules
- **CLAUDE.md** - Global behavior, generation, and formatting rules for Claude Code. Applied automatically to all interactions.
  - Note: These settings can also be copy-pasted into the Cursor IDE in order to apply globally.
- **CHATGPT.md** - Concise rules for ChatGPT emphasizing direct, brief responses.

### Statusline
- **scripts/claude-statusline.js** - Claude Code `statusLine` command: model name, current directory, and a context-usage bar. `install.sh` links it to `~/.claude/statusline.js` and points `~/.claude/settings.json`'s `statusLine` key at it.

### Output-conformance hooks

`CLAUDE.md` loads once, at the top of the context window, so a long session buries it and the model drifts back to preambles, em dashes, and flagged vocabulary. One hook closes that gap without asking you anything. `install.sh` links both files into `~/.claude/hooks/` and registers the script in `~/.claude/settings.json`.

- **hooks/output-contract.md** - the `CLAUDE.md` output rules that fail most often, restated in positive form with five before-and-after examples. `CLAUDE.md` stays the source of truth.
- **hooks/inject-contract.py** - `UserPromptSubmit` hook, the only registration. Appends the contract to every prompt as `additionalContext`, so the rules sit beside the tokens the model is about to write instead of thousands of tokens above them.

Nothing inspects the reply afterward, and that is deliberate. A `Stop` hook fires once the turn ends, so it can only block a finished message and make the model send a second one. A `MessageDisplay` hook can only add a line of its own under the reply. Both answers add noise where you asked for a clean message, so the contract has to land the first message instead.

Nothing here runs on request either. Both files in `hooks/` take part in every prompt, and anything that needed a person to start it has been removed. `inject-contract.py` uses only the Python standard library, so it needs no install step and makes no network call.

Editing `output-contract.md` changes what the next prompt carries. The file takes effect immediately, because `install.sh` links it rather than copying it.

### Skills
- **skills/agent-instructions/** - The AGENTS.md open standard for portable AI agent instructions.
- **skills/ask-questions/** - Systematic problem analysis and solution path optimization.
- **skills/browser-tools/** - Browser tool selection, Chrome isolation, and browser-harness execution.
- **skills/commit-push/** - Commits and pushes changes following Conventional Commits v1.0.0.
- **skills/explicit/** - Direct, low-decoding writing grounded in shared visible context.
- **skills/external-services/** - Credentials, environment variables, and API conventions for third-party services.
- **skills/humanize/** - Audits writing for AI patterns; detect, rewrite, or edit modes.
- **skills/masticulate/** - Walks through an existing numbered list one item at a time.
- **skills/quiz/** - Builds a mnemonic recall scaffold and quizzes one prompt at a time.

---

## Setup Instructions

The easiest way to configure all supported assistants is to run the install script. It creates symlinks so future updates to this repository apply automatically.

```bash
# Clone the repository
git clone https://github.com/jkhines/ai-rules.git ~/src/ai-rules
cd ~/src/ai-rules

# Link rules, skills, hooks, and MCP servers for Claude Code, Cursor, and OpenCode
./install.sh
```

### Claude Code

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) reads configuration from the `~/.claude/` directory and `~/.claude.json`. `install.sh` automatically:
- Symlinks global rules (`CLAUDE.md`)
- Symlinks all skills into `~/.claude/skills/`
- Configures the custom statusline and output-conformance hook in `~/.claude/settings.json`
- Links `~/.claude.json` to configure MCP servers from `mcp.json`

### Cursor

[Cursor](https://cursor.com/) uses a similar structure. `install.sh` automatically:
- Symlinks all skills into `~/.cursor/skills/`
- Links `~/.cursor/mcp.json` to configure MCP servers from `mcp.json`

For global rules in Cursor, you must apply them manually:
1. Open `Cursor Settings > General > Rules for AI`
2. Paste the contents of `CLAUDE.md`

### OpenCode

[OpenCode](https://opencode.ai/) keeps its global configuration in `~/.config/opencode/`. `install.sh` links `CLAUDE.md` to `~/.config/opencode/AGENTS.md`, which is the global rules file OpenCode reads, and merges the MCP servers from `mcp.json` into the `mcp` key of `~/.config/opencode/opencode.json`. The merge touches only the keys it manages, so your providers, permissions, and other settings survive a rerun.

Skills need no link of their own. OpenCode auto-loads every skill in `~/.claude/skills/`, which `install.sh` already fills. The install script also creates thin command adapters in `~/.config/opencode/commands/` so you can trigger any repository skill as a custom command (e.g. `/humanize`).

The same merge sets the default model to `openrouter/openai/gpt-5.6-sol`. OpenCode reads the OpenRouter credential from the `OPENROUTER_API_KEY` environment variable, so the provider itself needs no entry in the config file.

```bash
# Confirm OpenCode sees the servers
opencode mcp list
```

OpenCode loads its configuration once at startup, so restart it after a rerun.

The output-conformance hook does not carry over. It is registered as a Claude Code `UserPromptSubmit` hook, and OpenCode publishes no equivalent hook for a plugin to append context to each prompt.

### ChatGPT

[ChatGPT](https://chat.openai.com/) does not support file-based configuration. Instead, copy rules into the Custom Instructions setting:

1. Open ChatGPT and go to `Settings > Personalization > Customize ChatGPT`
2. Ensure "Enable customization" is toggled ON
3. Paste the contents of `CHATGPT.md` into the Custom Instructions field
4. Instructions apply to all new conversations (1,500 character limit)

---

## Keeping Rules Updated

With symlinks, pulling updates from this repository automatically updates your configurations for Claude Code, Cursor, and OpenCode. Note that when adding new skills or updating MCP servers, you should re-run `./install.sh`.

```bash
cd ~/src/ai-rules
git pull
```

---

## License

This work is dedicated to the public domain under CC0 1.0 Universal.

