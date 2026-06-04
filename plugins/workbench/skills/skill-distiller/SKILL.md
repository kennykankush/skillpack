---
name: skill-distiller
description: Distill a successful chat, project workflow, or repeated agent behavior into a reusable Codex or Claude skill. Use when the user wants to "skillify" a process, create a new skill from what just worked, generalize a workflow without overfitting one project, or update a skillpack/plugin with reusable instructions.
---

# Skill Distiller - Workflow To Reusable Skill

This skill turns a successful interaction pattern into a reusable agent skill.

It is a meta-workflow: it extracts what mattered, removes one-off details, writes a clear `SKILL.md`, and places it in the right skillpack or plugin structure when asked.

## Activation

Use this skill for requests like:

- "make this into a skill"
- "skillify this workflow"
- "distill what we did"
- "what did you need to know before executing?"
- "make a videos/storyboard skill"
- "add this to my skillpack"
- "create a reusable Codex skill from this"

Do not use this skill for ordinary task execution unless the user wants the workflow itself captured.

## Preflight

Before writing files, establish:

- target host: Codex, Claude Code, both, or host-agnostic
- target package: existing plugin, flat skill folder, project-scoped skill, or new plugin
- skill name and namespace
- trigger phrases
- workflow scope: what this skill should do
- explicit exclusions: what this skill should not do
- required companion skills or tools
- safety boundaries: file edits, generation, web research, destructive actions
- required outputs
- what must remain general instead of project-specific

If the user is still shaping the concept, discuss foundations first. Do not rush into files.

## Distillation Questions

Use these to extract the skill:

- What did the user repeatedly care about?
- What mistakes did earlier attempts make?
- What did the agent need to inspect before acting?
- What decisions had to be confirmed before execution?
- What outputs made the workflow useful?
- Which constraints were taste-specific, and which were generally useful?
- Which tool pairing was essential?
- What failure modes should future agents detect?
- Which examples help without becoming mandatory one-off rules?

## Generalization Rules

Keep skills reusable.

Do:

- encode decision gates
- encode review criteria
- encode tool boundaries
- encode output formats
- encode failure diagnosis
- include examples as examples
- include "do not use for" boundaries
- state when to ask a concise question

Do not:

- hard-code one project's frame numbers, branch names, file paths, or product copy unless the skill is project-scoped
- turn a successful example into the only valid workflow
- bury important constraints in prose that is hard to scan
- mix unrelated workflows into one skill
- make the skill over-authoritative when the user still needs taste exploration
- install global symlinks when plugin discovery is the intended path

## Skill Shape

Default `SKILL.md` structure:

```text
---
name: <skill-name>
description: <trigger-oriented description>
---

# <Title>

<One paragraph job definition.>

## Activation
## Preflight
## Workflow
## Output Format
## Quality Gate
## What Not To Do
```

Add sections only when they create operational clarity.

## Placement Rules

Choose the narrowest natural home:

- Workbench: meta-agent workflows, research, memory, prompt translation, skill lifecycle, toolkit operations.
- Videos: storyboard, product-launch, AI-video handoff, batching, motion preproduction.
- Agents: reusable operating modes like review, watcher, observer, closeout.
- Extra: small personal workflows that do not belong in a larger vertical.
- Project-scoped skills: workflows that depend on one repo's domain or structure.

If the user says a plugin destination, use it.

## Implementation Workflow

1. Inspect existing plugin or skill folder conventions.
2. Draft the skill around triggers, boundaries, workflow, outputs, and failure modes.
3. Create the folder and `SKILL.md` with `apply_patch`.
4. Update local README/catalog files when the repo uses them.
5. Validate with `git diff --check` and any host validation commands that are available.
6. Leave unrelated dirty files alone.
7. Report created paths and what remains for plugin refresh/install.

## Update Existing Skills

When improving an existing skill:

- keep the current skill's purpose intact
- add generalized rules, not one-off examples as mandates
- preserve companion-tool requirements
- avoid bloating the skill with every past conversation detail
- place very specific provider notes in a separate skill if they are not central

## Output Format

When discussing before editing:

```text
Proposed skills:
- <name>: <purpose>

Questions before writing:
- <question>
```

When implementing:

```text
Created:
- <path>

Validation:
- <command>: <result>

Notes:
- <anything not refreshed or intentionally untouched>
```

## What Not To Do

- Do not create a skill if the user only asked for a one-time answer.
- Do not overfit a skill to the exact artifacts from one thread.
- Do not skip preflight when the target host or package is unclear.
- Do not edit memory files unless the user explicitly asks to update memory.
- Do not use destructive git commands.
- Do not touch unrelated dirty files.
