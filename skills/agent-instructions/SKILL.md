---
name: agent-instructions
description: >-
  The AGENTS.md open standard for writing portable AI agent instructions. Load when creating or updating
  any instruction, skill, rule, or configuration meant to be read by an AI coding agent (Claude Code,
  Codex, Cursor, or others).
---
# Agent instructions

- When creating or updating any instruction, skill, rule, or configuration meant to be read by an AI coding agent, follow the AGENTS.md open standard (https://agents.md). Every compliant agent (Claude Code, Codex, Cursor, and others) must be able to read the guidance, so never lock it into one vendor's proprietary memory or configuration store.
- Keep the canonical, portable instructions in an AGENTS.md file written as standard Markdown. Place it at the repository root; in a monorepo, add a nearer AGENTS.md inside a subproject that needs its own guidance. Agents read the nearest file in the directory tree, so the closest one takes precedence.
- Cover the context an agent needs to work in the repository: project overview, build and test commands, code style and conventions, testing instructions, security considerations, and deployment steps. Use whatever headings fit the content.
- When a tool-specific artifact is still required (for example a Claude Code skill), keep its substantive guidance in step with the AGENTS.md file and reference that file rather than duplicating divergent rules.

## Skills

- Write every skill to the Agent Skills specification (https://agentskills.io/specification): one directory per skill holding a `SKILL.md` whose YAML frontmatter starts on line 1. The `name` field must match the directory name, use only lowercase letters, numbers, and single hyphens, and stay within 64 characters. The `description` field must say what the skill does and when to use it, within 1024 characters. Put optional code in `scripts/`, background material in `references/`, and templates in `assets/`.
- Place a project skill in `.agents/skills/<name>/` and add a relative symlink at `.claude/skills/<name>` that points to it. Cursor CLI and OpenCode read `.agents/skills/` directly, Claude Code reads only `.claude/skills/`, and the symlink gives all three harnesses the same file. Do not keep a second copy in `.cursor/skills/`, because two copies drift apart.
- Place a user-level skill in `~/.claude/skills/<name>/`, which all three harnesses read. In the `ai-rules` repository, add the directory under `skills/` and rerun `./install.sh`, which creates the per-harness links and the OpenCode command adapter.
- Keep any field outside the specification optional in effect, because a harness that does not know the field ignores it. `disable-model-invocation` hides a skill from the model in Claude Code and Cursor CLI, but OpenCode ignores the field and still offers the skill, so a skill that must never run unasked must also state that condition in its own body.
- Verify a new skill in every harness before calling it done: confirm that Claude Code lists it, that Cursor lists it, and that OpenCode lists it. A skill that only one harness can see is not finished.
