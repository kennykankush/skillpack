---
name: skill-distiller
description: Distill a successful chat, project workflow, repeated agent behavior, or a way of thinking into a reusable Codex or Claude skill. Use when the user wants to "skillify" a process, capture a reasoning/voice mode that just worked, create a new skill from what just worked, generalize a workflow without overfitting one project, or update a skillpack/plugin with reusable instructions.
---

# Skill Distiller - Workflow To Reusable Skill

This skill turns a successful interaction pattern into a reusable agent skill.

It is a meta-workflow: it extracts what mattered, removes one-off details, writes a clear `SKILL.md`, and places it in the right skillpack or plugin structure when asked.

## Activation

Use this skill for requests like:

- "make this into a skill"
- "skillify this workflow"
- "distill what we did"
- "capture this way of thinking / this mode"
- "what did you need to know before executing?"
- "make a videos/storyboard skill"
- "add this to my skillpack"
- "create a reusable Codex skill from this"

Do not use this skill for ordinary task execution unless the user wants the workflow itself captured.

## Preflight

Before writing files, establish:

- skill archetype: a **procedure/workflow** skill (does a task) or a **thinking-mode/voice** skill (installs a way of reasoning). This changes the shape — see Skill Shape.
- target host: Codex, Claude Code, both, or host-agnostic
- host coupling: does the skill touch host-specific paths or tools? If not, keep it host-agnostic and add **no** host-selection logic — a pure-reasoning skill is agnostic by default.
- target package: existing plugin, flat skill folder, project-scoped skill, or new plugin
- skill name and namespace
- trigger phrases
- workflow scope: what this skill should do
- explicit exclusions: what this skill should not do
- the skill's own worst failure mode, and the guard built into the skill to defend against it
- required companion skills or tools
- safety boundaries: file edits, generation, web research, destructive actions
- required outputs
- what must remain general instead of project-specific

If the user is still shaping the concept, discuss foundations first. Do not rush into files.

## Distillation Questions

Use these to extract the skill:

- Is the prize a *procedure* or a *way of thinking / a voice*? If the latter, the feel is the spec — capture behavior and texture, not just steps.
- What did the user repeatedly care about?
- What mistakes did earlier attempts make?
- What did the agent need to inspect before acting?
- What decisions had to be confirmed before execution?
- What outputs made the workflow useful?
- Which constraints were taste-specific, and which were generally useful?
- Which tool pairing was essential?
- What is this skill's own worst failure mode, and how can its core discipline guard against it?
- What two maximally-different cases prove this generalizes? (you need at least two — see Avoiding Overfit)
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
- triangulate with two or more maximally-different worked examples (see Avoiding Overfit)
- include examples as examples, labeled as instances with the abstract procedure above them
- carry depth/provenance as "hidden bones" the agent uses but never recites at runtime
- give the skill a runtime escape hatch: when it should decline and what to do instead
- make the Quality Gate a falsifiable self-test with a redo trigger
- if the skill reads or writes a shared repo artifact (a ledger, map, or vision doc at
  repo root), name the artifact and which sibling skills also touch it — wiring is part
  of the skill
- include "do not use for" boundaries
- state when to ask a concise question

Do not:

- hard-code one project's frame numbers, branch names, file paths, or product copy unless the skill is project-scoped
- ship a skill with a single worked example — one point overfits
- turn a successful example into the only valid workflow
- recite a skill's "hidden bones" (academic scaffolding/provenance) to the user at runtime
- force the procedure template onto a thinking-mode skill
- bury important constraints in prose that is hard to scan
- mix unrelated workflows into one skill
- make the skill over-authoritative when the user still needs taste exploration
- install global symlinks when plugin discovery is the intended path

## Avoiding Overfit — the mechanism, not just the warning

"Don't overfit" is useless as a warning by itself. Use the mechanism:

- **Triangulate.** Use **two or more maximally-different worked examples**, not one. One
  example teaches the agent to memorize a point; two distant ones force it to generalize
  from the *delta* between them. Pick cases that differ in both *subject* and *frame*
  (e.g. a CLI harness reasoned about via biology AND a bug-fix orchestrator via supply-chain
  logistics — different target, different source domain).
- **Examples are calibration, not scope.** Say so inside the skill: the examples tune the
  *moves and the voice* — they are **not** the menu of allowed inputs. Put the abstract
  procedure *above* the examples, label each one "one instance," and instruct the agent to
  re-run from scratch and never default to an example's domain.
- **Strip the one-off residue.** Names, paths, numbers, and product copy from the source
  thread come out unless the skill is explicitly project-scoped.
- **Guard the skill's own failure mode.** Name the worst way *this* skill fails, then build
  the defense into the skill itself (the way a structural-analogy skill's "structural, not
  surface" guard is pointed back at the skill's own analogies).

## Skill Shape

First decide the **archetype** — it changes the shape.

### Procedure / workflow skills

For skills that *do a task* (research, review, memory capture, migration):

```text
---
name: <skill-name>
description: <trigger-oriented description>
---

# <Title>

<One paragraph job definition.>

## Activation
## When NOT to fire        # runtime escape hatch: shapes this skill should decline + what to do instead
## Preflight
## Workflow
## Output Format
## Quality Gate            # a falsifiable self-test, not just a heading (see below)
## What Not To Do
```

### Thinking-mode / voice skills

For skills that install a *way of reasoning or a conversational texture*. Here the **feel
is the spec** — numbered steps alone cannot capture it:

```text
---
name: <skill-name>
description: <trigger-oriented description>
---

# <Title>

<One paragraph: what the mode is and what it produces.>

## The feel — this IS the spec   # behavioral/voice rules: how it talks, what it never does
## When to proc / When NOT to proc
## The loop                       # the moves, as a palette, not a forced march
## Worked instances               # TWO+ maximally-different, labeled as instances
## Guardrails                     # including the skill guarding its own failure mode
## Quality gate                   # falsifiable: what a good run produced, else redo
## The lineage — hidden bones     # provenance/rigor the agent uses but NEVER recites at runtime
```

Add or drop sections only for operational clarity. Two rules apply to **both** archetypes:

- **Falsifiable Quality Gate.** A gate is a test, not a heading: *"a run is good only if it
  produced X; a run that produced Y without X failed — redo."* Always write the redo trigger.
- **Guard the skill's own failure mode.** Name this skill's worst way to fail, then build
  the defense into the skill itself.

## Placement Rules

Choose the narrowest natural home:

- Workbench: meta-agent workflows, research, memory, prompt translation, skill lifecycle, toolkit operations, reasoning/thinking modes.
- Videos: storyboard, product-launch, AI-video handoff, batching, motion preproduction.
- Agents: reusable operating modes like review, watcher, observer, closeout.
- Extra: small personal workflows that do not belong in a larger vertical.
- Project-scoped skills: workflows that depend on one repo's domain or structure.

If the user says a plugin destination, use it.

## Implementation Workflow

1. Inspect existing plugin or skill folder conventions.
2. Draft the skill around triggers, boundaries, workflow, outputs, and failure modes.
3. Create the folder and `SKILL.md` with the host's file-editing tool.
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
- Do not ship a skill with a single worked example — use two or more that differ in subject and frame.
- Do not force the procedure template onto a thinking-mode skill — capture its voice and feel instead.
- Do not let the agent recite a skill's "hidden bones" (provenance/scaffolding) to the user at runtime.
- Do not leave the Quality Gate as a vague heading — make it a falsifiable test with a redo trigger.
- Do not skip preflight when the target host or package is unclear.
- Do not edit memory files unless the user explicitly asks to update memory.
- Do not use destructive git commands.
- Do not touch unrelated dirty files.
