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
