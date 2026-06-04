# kennykankush-skillpack

My agent workbench loadout. The plugins I actually use day-to-day, packaged with the host-specific formalities each agent expects. One posture across all of them: deliberate, disciplined, no grab-bag.

The long-term goal is framework and AI agnostic: useful workflows should outlive any one runtime. Codex, Claude Code, and future agent hosts can each get a thin adapter, but the underlying tools should stay portable.

## Install

### Codex

For local development, add this repo as a marketplace from the repo root:

```
codex plugin marketplace add .
```

Or, after publishing the repo:

```
codex plugin marketplace add kennykankush/skillpack
```

Then restart Codex, open `/plugins`, install the plugin you need, and start a new thread. In Codex, invoke bundled workflows with namespaced skills such as `$workbench:devour`, `$workbench:research-report`, `$workbench:skill-advisor`, `$workbench:skill-distiller`, `$workbench:memory-scriber`, `$workbench:max-prompt`, `$videos:storyboard`, `$extra:trail-scriber`, `$agents:birdwatch`, or `$agents:autoreview`.

### Claude Code

Add the marketplace once, then install whichever plugins you want:

```
/plugin marketplace add github.com/kennykankush/skillpack
/plugin install workbench@kennykankush-skillpack
/plugin install extra@kennykankush-skillpack
/plugin install agents@kennykankush-skillpack
/plugin install videos@kennykankush-skillpack
/reload-plugins
```

## What lives here

### workbench

The plugin that manages meta / everyday tooling. Five areas, seven tools. Codex gets installable bundled skills and marketplace metadata; Claude Code gets plugin skills, slash commands, and agents.

- **Codebase mastery.** `devour` enters study and discovery mode before implementation. It builds a grounded atlas of a repo: terrain, runtime routes, temporal behavior, blast radius, safe extension points, verification commands, and unknowns.
- **Research.** `research-report` runs deep dives that converge to exactly two files (`notes.md` + a Quarto-rendered `report.html`). Two modes off the same engine: official (writes files) and scan (inline only, promotable).
- **Memory.** `memory-scriber` writes session residue into the active host's memory store: Claude Code project memory under `~/.claude/projects/<project-slug>/memory/`, or a mirrored Workbench project-memory convention under `~/.codex/memories/projects/<project-slug>/memory/` with Codex global files acting as routers.
- **Prompting.** `max-prompt` turns vague feedback, screenshots, taste, and product instinct into implementation-ready prompts for coding agents.
- **Skills (managing the toolkit itself).** `skill-advisor` reads your installed skill index and ranks 2 to 5 matches read-only. `skill-distiller` turns successful workflows into reusable skills. `skill-manager` (Claude agent) handles the full lifecycle across three install mechanisms (plugins, npx skills, skillfish), always proposing before executing.

Full breakdown: [`plugins/workbench/README.md`](plugins/workbench/README.md)

### extra

A separate shelf for small personal workflows that are useful enough to package but do not belong in Workbench.

- **Trail.** `trail-scriber` reconstructs day-by-day work logs from Codex and Claude conversation evidence into Obsidian-friendly day, agenda, domain, and conversation notes. It uses commands to locate evidence, then relies on interpretation of the user's messages instead of keyword-only summaries.

Full breakdown: [`plugins/extra/README.md`](plugins/extra/README.md)

### agents

Reusable agent operating modes, kept separate from Workbench meta-tools and Extra's personal workflows.

- **Birdwatch.** `birdwatch` puts the assistant into live watcher mode while you test an app or product flow. It observes logs, APIs, DB rows, browser state, branch state, PRs, and issue state; writes evidence-backed findings; and avoids destructive state changes unless explicitly asked.
- **Autoreview.** `autoreview` vendors OpenClaw's structured closeout/code-review helper into the Agents pack. It reviews local changes, branch diffs, or commits; verifies accepted findings against the real code; and reruns until no actionable findings remain.

Full breakdown: [`plugins/agents/README.md`](plugins/agents/README.md)

### videos

Preproduction workflows for product-launch and AI-video-ready motion work.

- **Storyboard.** `storyboard` creates cohesive product-launch frame sets with Codex imagegen, prompt logging, and frame-by-frame quality gating.
- **Narrative and taste.** `launch-narrative` shapes the product film spine, while `style-contract` captures the reusable visual rules from screenshots, brand assets, and references.
- **Production handoff.** `frame-qa` reviews generated frames, `batch-prep` creates upload-ready folders, and `motion-handoff` writes keyframe prompts and node workflows for AI video tools.

Full breakdown: [`plugins/videos/README.md`](plugins/videos/README.md)

### More coming

A plugin lands here once it has stuck in my own setup long enough that I trust it. Experiments stay in dotfiles.

New plugins should be portable first, host-specific second. If a workflow only works in one agent, that is fine, but the boundary should be explicit.

## The shape

```
workbench   -> how I work with coding agents (meta)
extra       -> small personal workflows outside the main Workbench bundle
agents      -> reusable agent operating modes
videos      -> product-launch and AI-video motion preproduction
...         -> other domains as they emerge
```

Each plugin is a vertical: a coherent slice of one workflow domain, not a random pile of skills. They share a posture but stay independent. Install only what you need.

## Why plugins, not flat skills

I've run several skill-install mechanisms in parallel: Codex plugins, Claude plugins, `npx skills`, skillfish, and manual folders. I wrote my own meta-agent (`skill-manager`) just to coordinate them. So I get the appeal of flat skills: one command, one file, no scaffolding. For a one-off skill, that's the right move.

The catch is heavy use. If you actually rely on skills as a primary way of working with agents, the mess compounds. Skills sprawl across mechanisms. Names collide. Related tools end up scattered. Uninstalling leaves orphans. After living with all of it, the lesson is simple: plugins are the only mechanism that actually compartmentalizes a workflow.

What plugins give you that flat skills don't:

1. **A namespace.** Codex gets the `workbench` plugin boundary and bundled skill names. Claude Code gets `/workbench:research` and `/workbench:scan`. Flat skills compete in one global pool.
2. **A bundle.** Workbench has related tools that depend on each other. `skill-advisor` reads the index `skill-manager` regenerates. `memory-scriber` targets host-aware project memory while `research-report` writes project research artifacts. A plugin ships them as one unit. Flat skills install one at a time.
3. **Skills and supporting assets together.** Plugins bundle related skills, templates, scripts, apps, and MCP config under one roof. Codex currently loads the skills side of the bundle. Claude Code also supports commands and agents in this package.
4. **Clean install and uninstall.** One command brings the vertical in, one takes it out. `npx skills remove` famously leaves orphan folders in `~/.agents/skills/` (it's why my `skill-manager` agent has dedicated cleanup logic for it). Plugins clean up properly.
5. **Versioning and a discoverable home.** Plugin marketplaces have semver, so you can pin, upgrade, or roll back the whole bundle. They're also browseable directories. Flat skills are scattered across whatever repos you happened to find them in.

The cost is a bit more scaffolding (`.codex-plugin/plugin.json`, `.claude-plugin/plugin.json`, `marketplace.json`). The payoff is that a plugin reads as a *thing* with a shape, instead of a cluster of skills you happen to have installed.

This isn't a replacement for `npx skills`, skillfish, or host-native extension mechanisms. They're still useful when you just want to grab one skill quickly. Plugins are for tools that work as a system.

## License

[MIT](LICENSE)
