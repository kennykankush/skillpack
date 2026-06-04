# kennykankush-skillpack

Portable agent workflows I actually use.

This repo is my working layer for Codex, Claude Code, and any future agent host that can load the same underlying methods. The point is not to collect prompts. The point is to package durable ways of working: study the system before changing it, verify claims against live evidence, preserve the user's intent, converge messy work into clean artifacts, and keep each workflow in a namespace that can be installed or removed cleanly.

Plugins are the organizing unit. A plugin should feel like a coherent vertical, not a folder of unrelated tricks.

## Quickstart

### Codex

From the repo root:

```bash
codex plugin marketplace add .
```

Restart Codex, open `/plugins`, install the plugin you want, then start a new thread.

Common invocations:

```text
$workbench:devour
$workbench:research-report
$workbench:max-prompt
$agents:birdwatch
$agents:autoreview
$videos:storyboard
$extra:trail-scriber
```

After publishing, the marketplace can be added by repo instead:

```bash
codex plugin marketplace add kennykankush/skillpack
```

### Claude Code

Add the marketplace once:

```text
/plugin marketplace add github.com/kennykankush/skillpack
```

Install the bundles you want:

```text
/plugin install workbench@kennykankush-skillpack
/plugin install agents@kennykankush-skillpack
/plugin install videos@kennykankush-skillpack
/plugin install extra@kennykankush-skillpack
/plugin install agent-announcer-when-agent-finishes@kennykankush-skillpack
/reload-plugins
```

## Why this exists

I built this pack around the failure modes I keep seeing when agents become part of real work instead of one-off demos.

### #1: The agent changes code before it understands the system

The failure mode is shallow context. The agent reads the nearest files, makes a plausible edit, and misses the route, lifecycle, schema, auth state, test seam, or live behavior that actually controls the bug.

The fix is `workbench:devour`: a codebase mastery mode that builds a grounded atlas before implementation. It maps entrypoints, runtime flows, temporal behavior, blast radius, safe extension points, verification commands, and unknowns. The goal is judgment, not file-count tourism.

### #2: Research turns into tabs, notes, and abandoned scratch files

The failure mode is research sprawl. A topic starts with a useful question and ends with fragments spread across chat, browser history, Markdown scraps, and half-rendered drafts.

The fix is `workbench:research-report`: one research engine with two outputs. Scan mode answers inline when the question is lightweight. Official mode converges to exactly `notes.md` and `report.html` under `research/<umbrella>/<title>/`. The shape matters because the end state stays inspectable.

### #3: Taste gets lost between feeling and implementation

The failure mode is vague feedback. "This feels off" becomes random CSS churn, generic polish, or a prompt that describes the desired mood without telling an engineer what to change.

The fix is `workbench:max-prompt` for UI/product feedback and the `videos` pack for motion work. `max-prompt` translates instinct into mechanism, ownership, constraints, implementation direction, and verification. `videos` separates narrative, visual contract, storyboard generation, frame QA, batching, and motion handoff so taste does not collapse into a single generation prompt.

### #4: Live product work needs evidence, not confidence

The failure mode is guessing from stale memory. A user tests an app, the agent summarizes vibes, and nobody checks the logs, API, DB rows, browser state, branch state, PR state, or issue state that would prove what happened.

The fix is `agents:birdwatch`: a live watcher posture for product/dev sweeps. It observes first, records discrepancies, separates user-visible friction from backend/data bugs, and avoids destructive actions unless explicitly asked. For code closeout, `agents:autoreview` runs a structured review helper, verifies accepted findings against the real code path, applies narrow fixes only when appropriate, and reruns until no actionable findings remain.

### #5: Agent skills become a scattered toolbox

The failure mode is flat skill sprawl. Useful workflows get installed through different mechanisms, names collide, related tools drift apart, and uninstalling leaves leftovers.

The fix is plugin-first packaging. Each vertical has its own namespace, metadata, README, skills, commands, scripts, and host adapters. `workbench:skill-advisor` helps choose from the installed toolkit. `workbench:skill-distiller` turns a successful workflow into a reusable skill. The Claude-side `skill-manager` agent handles lifecycle across plugins, `npx skills`, skillfish, and manual installs.

### #6: Important handoffs should reach you when the agent is done

The failure mode is invisible completion. Multiple terminal tabs are running, one agent finishes or requests input, and the result sits unnoticed.

The fix is `agent-announcer-when-agent-finishes`: a hook plugin that speaks a one-line contextual handover with the Ghostty tab number. It can summarize through OpenAI-compatible chat endpoints and speak through local Qwen, ElevenLabs, OpenAI TTS, or macOS `say`.

## Methodology

The shared posture across this repo:

- **Portable first.** The core workflow should outlive Codex, Claude Code, or any single model. Host-specific commands and manifests are adapters.
- **Evidence before narration.** If live state is cheap to inspect, inspect it before explaining it.
- **Vertical bundles over grab bags.** A plugin should represent one workflow domain with clear boundaries.
- **Human-gated mutation.** Watching, reviewing, researching, and reconstructing can be active without being destructive.
- **Converged artifacts.** Research, memory, trail reconstruction, storyboard batches, and review closeout should have clear final states.
- **User voice matters.** Some workflows preserve exact phrasing because wording carries intent that summaries often erase.
- **Install only what earns its place.** Experiments can live elsewhere. A plugin lands here after it has proven useful in day-to-day work.

## Reference

### Workbench

Everyday meta-work for coding agents.

- [`workbench:devour`](plugins/workbench/skills/devour/SKILL.md) - Codebase mastery mode before risky implementation, refactors, migrations, debugging, or onboarding.
- [`workbench:research-report`](plugins/workbench/skills/research-report/SKILL.md) - Deep research with scan mode for inline answers and official mode for `notes.md` plus rendered `report.html`.
- [`workbench:memory-scriber`](plugins/workbench/skills/memory-scriber/SKILL.md) - Captures the residue of a meaningful session into the active host's memory directory.
- [`workbench:max-prompt`](plugins/workbench/skills/max-prompt/SKILL.md) - Converts fuzzy feedback, screenshots, taste, or frustration into an implementation-ready coding-agent prompt.
- [`workbench:skill-advisor`](plugins/workbench/skills/skill-advisor/SKILL.md) - Recommends from already-installed skills without installing anything.
- [`workbench:skill-distiller`](plugins/workbench/skills/skill-distiller/SKILL.md) - Generalizes a successful workflow into a reusable `SKILL.md`.
- `skill-manager` - Claude Code agent for discovering, installing, updating, and cleaning up skills across multiple mechanisms.

Full plugin docs: [`plugins/workbench/README.md`](plugins/workbench/README.md)

### Agents

Reusable operating modes for live work and closeout.

- [`agents:birdwatch`](plugins/agents/skills/birdwatch/SKILL.md) - Evidence-backed watcher mode while a user tests a product flow, API, DB state, logs, issues, or PR behavior.
- [`agents:autoreview`](plugins/agents/skills/autoreview/SKILL.md) - Structured code-review closeout for local changes, branch diffs, or commits, with verified findings and focused fixes.

Full plugin docs: [`plugins/agents/README.md`](plugins/agents/README.md)

### Videos

Product-launch and SaaS motion preproduction.

- [`videos:launch-narrative`](plugins/videos/skills/launch-narrative/SKILL.md) - Shapes the product film spine before visual generation.
- [`videos:style-contract`](plugins/videos/skills/style-contract/SKILL.md) - Captures visual rules from product screenshots, brand assets, and references.
- [`videos:storyboard`](plugins/videos/skills/storyboard/SKILL.md) - Generates cohesive storyboard frames with Codex imagegen and quality gates.
- [`videos:frame-qa`](plugins/videos/skills/frame-qa/SKILL.md) - Reviews frames or contact sheets and gives keep/regenerate decisions.
- [`videos:batch-prep`](plugins/videos/skills/batch-prep/SKILL.md) - Copies accepted frames into upload-ready AI-video batches with manifests and prompt placeholders.
- [`videos:motion-handoff`](plugins/videos/skills/motion-handoff/SKILL.md) - Writes keyframe prompts and node workflows for tools like Higgsfield Canvas, Gemini/Omni, Runway, and Krea.

Full plugin docs: [`plugins/videos/README.md`](plugins/videos/README.md)

### Extra

Personal workflows that are durable enough to package but do not belong in Workbench.

- [`extra:trail-scriber`](plugins/extra/skills/trail-scriber/SKILL.md) - Reconstructs day-by-day work trails from Codex and Claude conversation evidence into Obsidian-friendly day, agenda, domain, and conversation notes.

Full plugin docs: [`plugins/extra/README.md`](plugins/extra/README.md)

### Hooks

Small runtime utilities that make agent work easier to notice.

- [`agent-announcer-when-agent-finishes`](plugins/agent-announcer-when-agent-finishes/README.md) - Speaks a contextual one-line handover when Codex or Claude finishes a turn or needs input.

Full plugin docs: [`plugins/agent-announcer-when-agent-finishes/README.md`](plugins/agent-announcer-when-agent-finishes/README.md)

## Repository shape

```text
plugins/
  workbench/                         meta-work: devour, research, memory, prompting, skill tooling
  agents/                            reusable operating modes: birdwatch, autoreview
  videos/                            launch-film and AI-video preproduction
  extra/                             personal workflows outside Workbench
  agent-announcer-when-agent-finishes/ hook-based spoken completion handoffs
```

Each plugin carries its own host metadata:

```text
.codex-plugin/plugin.json
.claude-plugin/plugin.json
```

The root marketplace files expose the bundle:

```text
.agents/plugins/marketplace.json
.claude-plugin/marketplace.json
```

## Why plugins, not flat skills

Flat skills are useful for quick experiments. This repo is for workflows I depend on.

Plugins give the pack a few properties that matter in daily use:

1. **Namespacing.** `workbench`, `agents`, `videos`, and `extra` stay distinct instead of competing in one global list.
2. **Bundling.** Related skills, commands, scripts, templates, hooks, and metadata travel together.
3. **Clean lifecycle.** Install, upgrade, pin, or remove a vertical as a unit.
4. **Host adapters.** Codex and Claude Code can expose different commands while sharing the same method.
5. **A discoverable home.** A plugin reads as a maintained workflow package, not a scattered set of files.

The cost is a bit of manifest scaffolding. The payoff is a toolkit with boundaries.

## License

MIT.
