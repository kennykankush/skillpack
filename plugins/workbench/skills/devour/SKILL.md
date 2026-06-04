---
name: devour
description: Enter codebase mastery mode before implementation. Use when the user asks to DEVOUR a repo or codebase, learn everything, deeply onboard, map architecture, trace runtime flows, understand blast radius, or build intuition about where and when things happen in a system.
---

# Devour - Codebase Mastery Mode

Devour is a study and discovery mode for building a working mental model of a codebase. The job is not to summarize files like a tourist. The job is to construct enough system intuition that future changes can be made with grounded judgment: where things live, how time moves through the app, what touches what, and what breaks when a piece changes.

## Activation

Use this skill when the user asks for any of these:

- "DEVOUR this codebase"
- "devour the repo"
- "learn everything here"
- "deeply understand this codebase"
- "map this system before we change it"
- "onboard yourself to this repo"
- "figure out the architecture and blast radius"

Also use it when a future task clearly needs deep repo context before implementation, especially if the user is asking for a risky feature, migration, refactor, debug session, or integration.

## Host-Agnostic Contract

This skill must work in Codex, Claude Code, and other coding-agent hosts.

- Use whatever file, search, shell, git, browser, log, test, and database-inspection tools the active host exposes.
- Do not rely on host-specific tool names in the final output.
- Prefer fast structured discovery tools when available, such as file search, text search, dependency graph commands, package scripts, test runners, and framework CLIs.
- Report important commands and probes in plain terms so another host could repeat them.
- If a host lacks a tool, adapt the workflow instead of abandoning the skill.

## Operating Boundary

Devour is allowed to run safe local discovery commands when useful:

- list and search files
- read code, docs, config, manifests, scripts, tests, CI, and infra
- inspect git status, branches, recent commits, and diffs
- run bounded lint, typecheck, test, build, health, and diagnostic commands
- start or probe local services when needed for runtime understanding
- inspect logs and read-only database/schema state when credentials and tooling are already available
- browse official docs for external libraries or APIs when current behavior matters

Devour must not silently mutate the project.

- Do not edit code while devouring unless the user explicitly shifts from study to implementation.
- Do not run destructive commands, reset git state, apply migrations, wipe data, rotate credentials, push commits, deploy, or change remote state without explicit permission.
- Do not mutate local auth, routing, database rows, or user state unless the user asks for that kind of probe.
- If a command may be slow, costly, stateful, or destructive, say why and ask or choose a safer read-only substitute.
- If starting a long-running server is necessary, track it, report the URL or process, and stop it when it is no longer needed unless the user wants it left running.

## Study Stance

Treat the codebase like a living city with space and time.

- **Spatial awareness:** packages, boundaries, entrypoints, shared modules, routes, schemas, UI surfaces, service layers, tests, config, infra, scripts, and generated code.
- **Temporal awareness:** boot order, request lifecycle, UI state transitions, async jobs, queues, webhooks, migrations, caches, retries, deploy/build sequence, and historical churn.
- **Intuition:** if one piece changes, know the likely callers, consumers, side effects, tests, logs, and fragile nearby assumptions.

Do not claim mastery just because many files were opened. Mastery means the agent can answer practical change questions with evidence.

## Preflight

Before deep study:

1. Identify the real repo root and current working directory.
2. Check current git branch and dirty state; do not disturb unrelated changes.
3. Identify workspace shape: monorepo, app folders, packages, services, generated folders, vendored dependencies, docs, and scripts.
4. Read top-level orientation files first: README, AGENTS, CLAUDE, package manifests, build files, env examples, docs indexes, and architecture notes when present.
5. Ask at most one concise question only if the goal or safety boundary is genuinely ambiguous.

## Workflow

### 1. Surface Census

Build a complete surface map without wasting context on bulk output.

- Enumerate file types, directories, packages, apps, services, tests, docs, scripts, CI, infra, migrations, fixtures, and generated areas.
- Register ignored or generated folders without reading them unless they are central to the task.
- Identify package managers, language runtimes, framework versions, build tools, and local dev commands.
- Note missing docs, stale docs, or contradictory docs.

For small repos, reading most files may be appropriate. For large repos, use search, manifests, imports, routes, tests, and call/caller paths to guide deeper reading.

### 2. System Topology

Turn the census into a map of the system.

- Frontend: pages, routes, layouts, state, data fetching, components, styling, assets, interaction surfaces.
- Backend: API routes, controllers, services, domain modules, auth, permissions, validation, serializers, background work.
- Data: schemas, migrations, seed data, ORM models, repositories, caches, search indexes, queues, external storage.
- Integrations: third-party clients, webhooks, SDKs, env vars, credentials, rate limits, retries, failure handling.
- Operations: scripts, CI, deployment, Docker, observability, logs, health checks, feature flags.

Name the major subsystems and their boundaries. If boundaries are leaky, say where and how.

### 3. Runtime Routes

Trace actual flows from trigger to consequence. Prefer evidence from code paths, tests, scripts, logs, and local probes.

For each important route, map:

```text
trigger -> entrypoint -> domain logic -> persistence/external calls -> side effects -> response/UI/log/test
```

Cover the most important categories that exist in the repo:

- app boot and initialization
- primary user flows
- API request lifecycle
- form/action lifecycle
- auth/session lifecycle
- database write path
- background job or scheduler path
- webhook or integration path
- CLI/script path
- test execution path

### 4. Temporal Map

Study how time moves through the system.

- What runs before anything else?
- What depends on previous state?
- What is synchronous, async, delayed, retried, cached, queued, debounced, or scheduled?
- What state transitions exist?
- What events or logs mark progress?
- What happens during install, dev startup, build, test, deploy, migration, and runtime?
- What has changed recently in git history, and which areas churn often?

This section is what turns architecture knowledge into operational intuition.

### 5. Coupling And Blast Radius

Build a practical "if touched, inspect these too" map.

Look for:

- shared types, constants, helpers, schemas, validators, and generated clients
- global CSS/theme/state/config
- database schema consumers
- environment variables and feature flags
- public API contracts
- auth and permission checks
- test fixtures and snapshot assumptions
- background jobs, queues, webhooks, and retry paths
- code that looks local but is imported widely

For each high-risk area, state the blast radius and the verification path.

### 6. Live Probes

Run safe probes when they improve the map.

Good probes include:

- package script discovery
- lint/typecheck/test/build commands with bounded scope
- framework route listing
- local health endpoints
- read-only database schema inspection
- log tailing in a separate session
- browser walkthroughs of local UI flows
- CLI dry-runs or help commands

When probes fail, capture the exact failure and infer carefully. A failed probe is useful evidence, not a reason to hand-wave.

### 7. Synthesis

Compress the study into an atlas the user can use.

Default output:

```text
Devour Atlas

Repo Identity
- what this codebase is
- languages/frameworks/package managers
- real root and major apps/packages

Terrain Map
- major subsystems and where they live
- important boundaries and shared layers

Runtime Routes
- key flows traced end to end
- entrypoints, persistence, side effects, tests/logs

Temporal Map
- boot/build/test/deploy/runtime order
- async jobs, retries, caches, migrations, state transitions

Blast Radius Map
- if you touch X, inspect Y
- fragile zones, shared contracts, high-churn areas

Change Playbook
- safe extension points
- commands to verify changes
- files to inspect before common edits

Unknowns And Next Probes
- what is still unknown
- what evidence would close each gap

Readiness
- what kinds of changes the agent is now ready to make
- what still requires deeper study
```

Use file references when the host supports them. Avoid huge paste dumps. The value is in the connected map.

## Quality Gate

Before saying the repo has been devoured, check whether you can answer:

- Where does the app start?
- How does a primary user action move through UI, API, data, and side effects?
- Where is state stored, cached, transformed, and invalidated?
- Which modules are safe extension points?
- Which modules are risky because they are shared, temporal, or under-tested?
- If a schema, route, component, helper, or config file changes, what else must be inspected?
- Which commands verify the important paths?
- What did live probes prove, and what did they fail to prove?

If you cannot answer these with evidence, say the codebase is partially devoured and list the next probes.

## Progress Discipline

For long devours:

- Send short progress updates as the map sharpens.
- Keep a running list of discovered subsystems, flows, and unknowns.
- Do not disappear into endless reading without synthesizing.
- If context or time is limited, produce a checkpoint atlas and say exactly what remains.
- Prefer continuing from the checkpoint over restarting from scratch.

## What Not To Do

- Do not produce a generic architecture summary detached from files and flows.
- Do not equate reading every file with understanding the system.
- Do not ignore tests, scripts, logs, config, migrations, and docs.
- Do not treat docs as truth when code contradicts them.
- Do not bury uncertainty. Unknowns are part of the atlas.
- Do not make code changes during devour mode unless asked.
- Do not pretend to know current external API behavior without checking official sources when it matters.
- Do not overwhelm the user with raw file listings when a connected map is more useful.
