# workbench

Everyday agent workbench. Six areas, fifteen skills, and a Claude-side lifecycle agent. Each skill works on its own; the [workflow recipes](WORKFLOWS.md) connect them around a shared outcome.

The workflow layer is meant to be portable. Codex, Claude Code, and future hosts can expose different invocation surfaces, while sharing the methods for understanding a system, finding opportunities, choosing a direction, testing an assumption, building, verifying, and preserving what matters.

## Install

### Codex

From the `skillpack` repo:

```
codex plugin marketplace add .
```

Restart Codex, open `/plugins`, install `workbench`, and start a new thread. Codex invokes the workflows as bundled skills: `$workbench:devour`, `$workbench:bedrock`, `$workbench:gauntlet`, `$workbench:potential`, `$workbench:decide`, `$workbench:probe`, `$workbench:vision`, `$workbench:isomorph`, `$workbench:scour`, `$workbench:totality`, `$workbench:research-report`, `$workbench:skill-advisor`, `$workbench:skill-distiller`, `$workbench:memory-scriber`, and `$workbench:max-prompt`.

### Claude Code

```
/plugin install workbench@kennykankush-skillpack
```

(Requires the `kennykankush-skillpack` marketplace added first — see [parent README](../../README.md).)

Claude Code loads the plugin skills as portable workflows. Invoke `devour` in plain language, for example: "DEVOUR this codebase before we change it."

## What's in it

### Codebase Mastery

**`devour`** — Codebase study and discovery mode. It builds a working atlas of the repo before implementation: surface census, system topology, runtime routes, temporal map, blast-radius map, live probes, safe extension points, and unknowns. The point is not to read many files; the point is to gain enough grounded system intuition to know where and when a change will matter. The atlas persists to `MAP.md` at the repo root — later devours, bedrock, and potential read it instead of starting from zero.

`devour refresh` reconciles that atlas with committed, staged, unstaged, and relevant untracked changes. It records revision and scope, corrects invalidated conclusions, and distinguishes newly verified areas from inherited understanding. A missing baseline is a reason to recheck the affected scope, not invent a change history.

**`bedrock`** — Foundation audit mode. After heavy build sprints, an adversarial inspector walks the building: stress-tests load-bearing logic to bank-grade (atomicity, double-fire, races, swallowed failures), limit-tests feature flows by actually running them, and files findings backed by runnable repros. Maintains an `AUDIT.md` ledger at repo root — every run opens with a regression sweep of past findings. Two modes: report (default) and report-then-fix.

**`gauntlet`** — Bedrock's bigger sibling: run the whole product through its trials. Drive a realistic, goal-driven user journey end to end as the spine, and at every action sweep-test the *real* subsystem behind it — a surface pass (breadth across the journey that triages each touchpoint into a risk-ranked hit-list) funnelling into a deep pass (depth on the risky stations: a varied + adversarial population, breadth × volume, independent verification). It proves both that the user's experience held and that the machinery is sound — skeptical, flaw-hunting, the strongest independent oracle each subsystem affords, run safely and reversibly (snapshot → sweep → restore). A fusion of deterministic simulation testing, agent playtesting, synthetic user journeys, and the test-oracle problem; bedrock runs code to ground a claim, gauntlet drives a whole stateful lifecycle as god + user and verifies the truth it computes.

The sweep retains useful findings and reproductions in the project's existing homes, reuses regression tests where available, and restores only its owned test state. The diary labels observed behavior separately from inferred user experience; an agent-driven journey does not count as human research.

**`potential`** — Bedrock's generative counterpart: the developer across the street who reads the structure and sees what it wants to become. Surfaces features the building already implies (squeeze, birth, combine, expose, generalize), each cited to real beams and graded by honest distance (already-built / one-beam / new-wing). Two modes: open ("what does this want to become?") and wish ("I wish it could X" — the structure answers). Conversational like isomorph; never implements, never writes files.

Each serious opportunity also names who benefits, ongoing ownership and operating burden, opportunity cost, and a smaller alternative. Structural distance and usefulness are assessed separately. `decide` can compare the resulting candidates when the user wants a recommendation.

**`vision`** — Keeps what the building is *for* on file: one `VISION.md` at the repo root holding the verbatim spark, the experience promise, non-goals, taste principles, and current direction. Three moments: birth (carry a warroom exploration's distilled intent into a new repo), backfill (projects already alive with no vision doc), refresh (the doc drifted from current intent). Constitutional rule: the vision comes from the visionary — evidence drafts, the user's voice decides. Devour, bedrock, and potential all read it.

### Thinking

**`decide`** — Turns credible options and evidence into a reasoned recommendation. Identifies the criteria that matter to the user, compares tradeoffs, challenges the leading option, and states what would change the decision. Distinguishes a recommendation from a choice the user made or delegated. Conversational by default; works independently or between exploration and authorized implementation.

**`probe`** — Resolves a consequential uncertainty with the smallest useful experiment. Defines outcomes, evidence, limits, authority, and cleanup before execution. Returns a supported, contradicted, or inconclusive result within its actual scope, then carries that evidence back to the decision. Technical feasibility, correctness, usability, and demand require different evidence. If execution is unavailable, it returns an explicitly unrun plan.

**`isomorph`** — Reason about a whole system by mapping it onto a mature, structurally-similar domain that already paid for its mistakes, then read that domain's laws back onto the system as invariants and blindspots. A thinking mode, not a file-producing workflow — with one exception: when the user adopts a twin as the project's design bible, it's recorded into `VISION.md` as the system shape, where bedrock audits against its laws, potential consults it for wishes, and devour labels the map in its language.

**`scour`** — The reality-check hotline. Mid-conversation, leave the closed room and go to the internet to ground what was just said. Two faces: verify (a confident narrative was just produced — pull the load-bearing claims and check each against real fetched sources: confirmed / wrong / oversimplified / outdated / no-consensus) and discover (stuck or starting fresh — find the dominant pattern and the gotchas). The evidence twin of isomorph; currency-aware (catches "true at training, the world moved"). Fast and conversational — never writes files, never answers from memory. Promotes to research-report when a reach cracks open something worth keeping.

**`totality`** — The exhaustive-surface cartographer. Maps the COMPLETE surface of any object (a resume, a domain, a dataset, a market, a decision space) with provable coverage instead of vibes: ANCHOR against official exhaustive taxonomies (diff, don't vibe — "a category with no entry is a bug"), ROTATE enumeration generators, expand every example into its full basket recursively (the Orange Rule: examples are seeds, never boundaries), stock the mandatory NICHE shelf (the overlooked is where the alpha lives), and SHOW the whole tree with statuses, an audit line, and an honest residual bucket. Three gears (quick / standard / ham). Guards its own failure modes: the infinite map (map maximally, act selectively) and fake MECE. The OMNI of the pack's type-object pattern — scour and research-report carry Totality Mode pointers to it; scour is its anchor-fetch engine.

### Research

**`research-report`** — Deep research that converges to exactly two artifacts: `notes.md` (raw consolidated dump) and `report.html` (polished, Quarto-rendered). No scratch files. No emojis. Two modes off the same engine:

- `/workbench:research <topic>` — official: writes both files into `research/<umbrella>/<title>/`
- `/workbench:scan <topic>` — quick: structured findings inline, no files. Promotable to official.
- Codex: invoke `$workbench:research-report` and say whether you want official mode or scan mode.

Umbrella domains (`marketing`, `engineering`, `uiux`, `product`, etc.) are deliberate taxonomy — pick the closest match.

### Memory

**`memory-scriber`** — Captures what a colleague internalizes from a working session — how you think, what you care about, where you left off. Not a summary. Not minutes.

- Codex mirrors Claude-style project memory under `~/.codex/memories/projects/<project-slug>/memory/`
- Codex global `MEMORY.md` and `raw_memories.md` act as routers to project memories
- Claude Code writes project memory: `~/.claude/projects/<project-slug>/memory/MEMORY.md` plus a dated session file
- The active host decides the target; it does not mirror between hosts unless asked
- The opening brief is sacred (verbatim user voice)
- The journey at the bottom is non-negotiable (chronological reconstruction)
- The middle is reflective, in your voice — not report categories
- Quote the user when their phrasing reveals something

### Skills (managing the toolkit itself)

Three related tools: one reads the toolkit, one distills successful workflows into reusable skills, and one manages lifecycle in Claude Code.

**`skill-advisor`** — Read-only matchmaker. Answers "which of my installed skills fits this task?" from your local index. Does not install. Does not browse. Ranks 2–5 candidates with one-line justifications, suggests where they fit in your workflow, and flags when a category is thin so you know to call `skill-manager`.

**`skill-distiller`** — Turns a successful chat, product workflow, or repeated agent behavior into a reusable `SKILL.md`. It extracts triggers, preflight questions, tool boundaries, output formats, quality gates, and anti-patterns while stripping away one-off project details.

**`skill-manager` (Claude agent, not yet a Codex plugin component)** — Lifecycle pipeline. Three install mechanisms (plugins, npx skills, skillfish) plus manual, each with their own namespacing, lock files, and cleanup quirks. Encodes which mechanism to use and the gotchas of each — orphan folders left by `npx skills remove`, marketplace-name lookup, cross-mechanism collision checks. Always proposes before executing. Default scope is user/global. After every install, regenerates `~/.agents/CATEGORIES.md` so `skill-advisor` stays current.

Discover mode researches new skills from marketplaces and GitHub, then hands the install decision back.

### Prompting

**`max-prompt`** — Turns vague intent into a grounded, execution-ready prompt for the right agent or tool. It adapts to software, architecture, operations, research, writing, product/UI, and creative work; recovers the real outcome, separates evidence from assumption, selects the relevant domain mechanics, and defines boundaries plus verification. Its central guard is against ornate wrongness: a beautifully detailed prompt built on invented certainty.

## How they fit together

```text
devour → potential → decide → implementation → verification
                       ↕
                     probe
```

This is one route for an existing product. Enter at the unresolved stage, skip stages
already satisfied by current evidence, and use only the skills needed for the task.
`vision` maintains intent, `scour` checks external understanding, `isomorph` explores
structure, and `totality` expands coverage when completeness matters. `max-prompt`
packages a handoff to another recipient; normal implementation can continue directly.

[WORKFLOWS.md](WORKFLOWS.md) contains three recipes: find and build an opportunity,
shape a new idea, and harden an existing product. Each defines entry conditions,
handoffs, skip rules, and useful final state. They share a compact record of the
outcome, evidence, decision, unknowns, and authorized next action. Standalone skill
requests still stop at their own output.

`skill-advisor` helps choose from the installed toolkit. `memory-scriber` preserves
session learning when requested, and `skill-distiller` captures a method that proved
useful. Neither preservation step is mandatory after ordinary work.

## Invocation Surfaces

### Codex

- `$workbench:research-report official <topic>` — full research pipeline
- `$workbench:research-report scan <topic>` — quick research scan, no files
- `$workbench:devour <repo/task>` — codebase mastery mode before implementation
- `$workbench:devour refresh [area]` — reconcile an existing map with changes and evidence
- `$workbench:bedrock [area] [fix]` — foundation audit; add `fix` for report-then-fix
- `$workbench:gauntlet <flow/system>` — drive a user journey end to end and sweep-test the machinery behind each step
- `$workbench:potential [wish]` — what the building wants to become; pass a wish for wish mode
- `$workbench:decide <choice>` — compare options, recommend a direction, and state when to revisit
- `$workbench:probe <assumption>` — run a bounded experiment, or say "plan only" to design it
- `$workbench:vision [backfill|refresh]` — write or revive the repo's VISION.md
- `$workbench:isomorph <system>` — map the system onto its mature twin
- `$workbench:scour [claim|problem]` — reality-check the conversation against the web
- `$workbench:totality <object>` — map the requested surface against explicit anchors
- `$workbench:skill-advisor <task>` — recommend from the installed toolkit
- `$workbench:skill-distiller` — distill a workflow into a reusable skill
- `$workbench:memory-scriber` — capture the current session
- `$workbench:max-prompt` — translate vague intent into a grounded prompt for the situation

### Claude Code

- `/workbench:research <topic>` — full research pipeline
- `/workbench:scan <topic>` — quick research scan, no files

Claude Code also loads Workbench skills and `skill-manager` as an agent. Codex uses bundled skills and natural language instead of custom plugin slash commands.

## The convergence rule (research-report)

Final state, no exceptions:

```
research/<umbrella>/<title>/
  notes.md          ← raw consolidated findings
  report.html       ← rendered polished read
  .build/           ← hidden: .qmd source, Quarto cache (gitignored)
```

`/research` is added to project `.gitignore` automatically.

## Dependencies

- **Quarto** — auto-installed to `~/.local/share/quarto/` on the first official research run. No sudo required.

## License

[MIT](../../README.md#license).
