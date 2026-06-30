---
name: devour
description: Enter codebase mastery mode before implementation. Use when the user asks to DEVOUR a repo or codebase, learn everything, deeply onboard, map architecture, trace runtime flows, understand blast radius, or build intuition about where and when things happen in a system. Persists its atlas to MAP.md at the repo root so later runs, bedrock, and potential start from the map instead of zero.
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

There is also a two-brain variant, triggered by `devour collab` (e.g. `/devour collab`,
`$devour collab`, optionally scoped: `devour collab src/api`). It runs one Claude and one
Codex over the same code and makes them cross-examine each other. See **Collab Mode** below.
Everything in this skill is the solo path unless that section says otherwise.

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

- Exception, and the only one: devour's declared artifact is `MAP.md` at the repo root
  (see Persist The Atlas). Writing or updating it is announced output, not silent
  mutation. Everything else stays read-only.
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
2. If `MAP.md` exists at the repo root, read it first: it is a prior devour's persisted
   atlas. Treat it as claims to verify, not truth — reconcile it against the real repo as
   you study, and note what has drifted since it was written.
3. Check current git branch and dirty state; do not disturb unrelated changes.
4. Identify workspace shape: monorepo, app folders, packages, services, generated folders, vendored dependencies, docs, and scripts.
5. Read top-level orientation files first: README, AGENTS, CLAUDE, VISION.md (the project's stated intent, when present), package manifests, build files, env examples, docs indexes, and architecture notes.
6. Ask at most one concise question only if the goal or safety boundary is genuinely ambiguous.

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

### Persist The Atlas

The atlas does not evaporate with the session. After synthesis, write it to `MAP.md` at
the repo root — create it on the first devour, reconcile and update it on every devour
after. Announce that it was written; if the user declines persistence, keep the atlas in
chat only.

Rules for `MAP.md`:

- One file, readable in one sitting. Weight budget is law: compress, collapse stale
  detail, never spawn a second map file.
- Stamp each update with the date and the scope of what was actually studied.
- If `VISION.md` declares an adopted system twin ("this is built as a hospital"), label
  the atlas in both languages where it helps — `sessions/ = the wards` — so the map
  speaks the building's own metaphor.
- Keep the Unknowns section honest — a map that hides its blank regions is worse than no
  map.
- Future readers (a later devour, `bedrock`, `potential`, any agent) must treat it as
  claims to verify, not truth. Write it so that spot-checking is easy: file references,
  not prose vibes.

This is what makes the family compound: bedrock orients its audit walk with `MAP.md`,
potential reads it as the structure to dream from, and the next devour starts from a
checkpoint instead of zero.

## Collab Mode

Triggered by `devour collab`. Solo devour is one mind. Collab runs two *different* minds —
one Claude, one Codex — over the same code, because their blindspots are **decorrelated**:
two of the same harness miss the same things; one of each do not. The point is not
throughput. It is catching what a single model is structurally blind to.

### Roles

- **Conductor** — the harness you invoked from. It does *not* devour. It launches the two
  brains, carries messages between them, and merges as a disinterested third party.
  Neutrality is the job: a conductor that also devoured would defend its own atlas.
- **Two brains** — always one Claude and one Codex, never two of a kind. Whichever harness
  is conducting, the *other* is spawned as the second brain, and the conductor's own
  harness is spawned as a fresh, separate process for the first brain — never the
  conductor's live session — so neither brain is also the judge.

Both brains run **read-only**. The conductor owns every file write; `MAP.md` stays
devour's only repo mutation.

### How They Talk

They do not hold a live conversation, and that is deliberate. They exchange **written
atlases through the conductor, in rounds** — like two reviewers trading written reviews,
not a phone call. Live chat would let them anchor on each other and re-correlate their
blindspots; the whole value is that each forms a *complete independent model first*, then
is forced to confront the other's.

**Round 1 — Independent (blind).** Each brain devours the scope alone and emits a Devour
Atlas. Neither sees the other. `file:line` references are mandatory here — they are what
let the peer verify in round 2. Run the two in parallel (background the first, run the
second alongside, join when both land):

```text
codex exec -s read-only -C <repo> -o <scratch>/atlas-codex.md  "$(cat <scratch>/brief.md)"
claude -p --permission-mode plan "$(cat <scratch>/brief.md)"  > <scratch>/atlas-claude.md
```

**Round 2 — Critique.** The conductor hands each brain the *other's* atlas: "Re-enter the
code and verify. Report (1) what they caught that you missed, (2) their claims you believe
are wrong — with `file:line` proof, (3) what you now think you both missed." Each re-reads
real files to check the other's citations. This is the blindspot exchange.

**Round 3 — Rebuttal (the actual conversation).** The conductor hands each brain the
critique written *about its own atlas*. Each concedes or defends with evidence. Two passes
of written exchange make a real, grounded dialogue — mediated and on the record, so the
conductor sees exactly where they converged and where they dug in. One critique+rebuttal
cycle by default; loop again only if the user asks or genuine disagreements remain open.

**Round 4 — Reconcile.** The conductor reads both atlases and the full exchange and writes
the merged `MAP.md`, adding the section a solo devour cannot produce:

- **Agreed map** — held by both, or asserted by one and verified by the other. Standard
  Devour Atlas sections.
- **Resolved** — what the exchange settled, with the deciding evidence.
- **Contested / Unverified** — genuine standoffs, both positions with their citations:
  `Claude: boot driven by init.ts:40. Codex: bootstrap.ts:12. Unresolved — inspect both.`
  This is where a human looks first.

Stamp the update: collab devour, the date, the scope, and the two harnesses with their
model ids.

### Mechanics And Guardrails

- **Scratch lives outside the repo** (a temp/session dir): `brief.md`, the two atlases,
  and the critique/rebuttal files. Only `MAP.md` lands in the repo. Drop scratch when done
  unless the user wants it kept.
- **The brief is self-contained.** Embed the condensed devour study contract, the scope,
  and the output format into `brief.md`, so each brain runs a real devour without
  depending on this skill being loaded in its host.
- **Read-only asymmetry, by design.** Codex's read-only sandbox can still run read-only
  probes (grep, tests that do not write); Claude in plan mode reads and reasons but will
  not run probes headless. If a probe matters, the conductor runs it and feeds the result
  into round 2. Note this rather than pretend symmetry.
- **Cost.** Roughly 2x a full devour plus the exchange, so it is opt-in. For a quick map,
  plain `devour` is right; reach for collab when the map must be *trusted* — before a risky
  migration, an unfamiliar inherited repo, or a foundation audit.
- **Host-agnostic.** Invoked from Claude → conductor Claude, brains `claude -p` +
  `codex exec`. Invoked from Codex → mirror image. Same contract either way.

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
- If context or time is limited, produce a checkpoint atlas, persist it to `MAP.md` with
  its Unknowns section marking exactly what remains, and say so.
- Prefer continuing from the checkpoint over restarting from scratch — that is what
  `MAP.md` is for.

## What Not To Do

- Do not produce a generic architecture summary detached from files and flows.
- Do not equate reading every file with understanding the system.
- Do not ignore tests, scripts, logs, config, migrations, and docs.
- Do not treat docs as truth when code contradicts them.
- Do not bury uncertainty. Unknowns are part of the atlas.
- Do not make code changes during devour mode unless asked.
- Do not pretend to know current external API behavior without checking official sources when it matters.
- Do not overwhelm the user with raw file listings when a connected map is more useful.
