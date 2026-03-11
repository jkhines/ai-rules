---
command: /spawn
description: Spawns strict parallel model agents, writes findings files, and optionally applies fixes
alwaysApply: false
---
Run one task across multiple models in parallel, require each model to persist findings to a local markdown file, and optionally implement fixes from the combined findings.

## Inputs

All inputs have defaults and only need to be specified when overriding.

- `task` -- delegated instruction (for example, `the /code-review command`)
- `models` -- target models. Default: `["opus-4.6","gpt-5.3-codex","gemini-3.1-pro"]`
- `output_dir` -- directory for findings files. Default: current working directory
- `timestamp` -- shared run timestamp. Default: current UTC `YYYYMMDD-HHmmss`
- `poll_interval_sec` -- file polling interval. Default: `2`
- `timeout_sec` -- max wait for all model outputs. Default: `900`
- `strict` -- when `true`, fail if any expected file is missing. Default: `true`
- `apply_severity` -- severities to implement after synthesis. Default: `[]` (no auto-implementation)
- `max_parallel` -- max concurrent spawned agents. Default: `3`

## Behavior

1. Parse the request into:
   - delegated task (for example, run `/code-review`)
   - target models
   - optional fix instruction (for example, implement Critical and High findings)
2. Normalize friendly model names to Cursor model IDs:
   - `Opus 4.6` -> `opus-4.6`
   - `Codex 5.3` -> `gpt-5.3-codex`
   - `Gemini 3.1 Pro` -> `gemini-3.1-pro`
3. Compute one shared `timestamp` and expected file per model:
   - `cursor-<model-id>-<timestamp>.md`
   - output path: `output_dir/cursor-<model-id>-<timestamp>.md`
4. Spawn one background sub-agent per model (up to `max_parallel`) with required instructions:
   - run the delegated `task`
   - write final findings to exactly `output_dir/cursor-<model-id>-<timestamp>.md`
   - end by reporting the exact local file path created
5. Poll `output_dir` until all expected files exist or `timeout_sec` is reached.
6. Enforce strict completion by default:
   - if all files exist, continue
   - if any file is missing and `strict=true`, fail the run and report missing files
   - if any file is missing and `strict=false`, continue with available files and mark partial completion
7. Read produced findings files and synthesize:
   - consolidated Critical/High/Medium/Low issue list
   - overlap and disagreement by model
   - ordered implementation plan
8. If the user requested implementation or `apply_severity` is non-empty:
   - map "Implement all Critical and High bug fixes" to `apply_severity=["Critical","High"]`
   - implement fixes in severity order
   - run verification after each fix group and iterate until passing
9. Return:
   - models spawned
   - file paths created
   - strict pass/fail result
   - synthesized enhancements
   - implementation outcomes (if requested)

## Required sub-agent instruction template

Use this exact structure for each spawned model:

1. Run: `<delegated task>`.
2. Save your final output to: `<output_dir>/cursor-<model-id>-<timestamp>.md`.
3. End with: `CREATED_FILE: <absolute-local-path>`.

## Example prompts

- `/spawn the /code-review command for Opus 4.6, Codex 5.3, and Gemini 3.1 Pro`
- `/spawn the /code-review command for Opus 4.6, Codex 5.3, and Gemini 3.1 Pro. Implement all Critical and High bug fixes suggested by the agents.`
