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

Then restart Codex, open `/plugins`, install `workbench`, and start a new thread. In Codex, invoke bundled workflows with `$workbench:research-report`, `$workbench:skill-advisor`, `$workbench:memory-scriber`, `$workbench:max-prompt`, or natural language.

### Claude Code

Add the marketplace once, then install whichever plugins you want:

```
/plugin marketplace add github.com/kennykankush/skillpack
/plugin install workbench@kennykankush-skillpack
/reload-plugins
```

## What lives here

### workbench

The plugin that manages meta / everyday tooling. Four areas, five tools. Codex gets installable bundled skills and marketplace metadata; Claude Code gets plugin metadata, slash commands, and agents.

- **Research.** `research-report` runs deep dives that converge to exactly two files (`notes.md` + a Quarto-rendered `report.html`). Two modes off the same engine: official (writes files) and scan (inline only, promotable).
- **Memory.** `memory-scriber` writes session residue into Codex native memory (`~/.codex/memories/MEMORY.md` plus `raw_memories.md`) with a legacy project-file fallback for other hosts.
- **Prompting.** `max-prompt` turns vague feedback, screenshots, taste, and product instinct into implementation-ready prompts for coding agents.
- **Skills (managing the toolkit itself).** `skill-advisor` reads your installed skill index and ranks 2 to 5 matches read-only. `skill-manager` (Claude agent) handles the full lifecycle across three install mechanisms (plugins, npx skills, skillfish), always proposing before executing.

Full breakdown: [`plugins/workbench/README.md`](plugins/workbench/README.md)

### More coming

A plugin lands here once it has stuck in my own setup long enough that I trust it. Experiments stay in dotfiles.

New plugins should be portable first, host-specific second. If a workflow only works in one agent, that is fine, but the boundary should be explicit.

## The shape

```
workbench   -> how I work with coding agents (meta)
...         -> other domains as they emerge
```

Each plugin is a vertical: a coherent slice of one workflow domain, not a random pile of skills. They share a posture but stay independent. Install only what you need.

## Why plugins, not flat skills

I've run several skill-install mechanisms in parallel: Codex plugins, Claude plugins, `npx skills`, skillfish, and manual folders. I wrote my own meta-agent (`skill-manager`) just to coordinate them. So I get the appeal of flat skills: one command, one file, no scaffolding. For a one-off skill, that's the right move.

The catch is heavy use. If you actually rely on skills as a primary way of working with agents, the mess compounds. Skills sprawl across mechanisms. Names collide. Related tools end up scattered. Uninstalling leaves orphans. After living with all of it, the lesson is simple: plugins are the only mechanism that actually compartmentalizes a workflow.

What plugins give you that flat skills don't:

1. **A namespace.** Codex gets the `workbench` plugin boundary and bundled skill names. Claude Code gets `/workbench:research` and `/workbench:scan`. Flat skills compete in one global pool.
2. **A bundle.** Workbench has related tools that depend on each other. `skill-advisor` reads the index `skill-manager` regenerates. `memory-scriber` targets host-native memory while `research-report` writes project research artifacts. A plugin ships them as one unit. Flat skills install one at a time.
3. **Skills and supporting assets together.** Plugins bundle related skills, templates, scripts, apps, and MCP config under one roof. Codex currently loads the skills side of the bundle. Claude Code also supports commands and agents in this package.
4. **Clean install and uninstall.** One command brings the vertical in, one takes it out. `npx skills remove` famously leaves orphan folders in `~/.agents/skills/` (it's why my `skill-manager` agent has dedicated cleanup logic for it). Plugins clean up properly.
5. **Versioning and a discoverable home.** Plugin marketplaces have semver, so you can pin, upgrade, or roll back the whole bundle. They're also browseable directories. Flat skills are scattered across whatever repos you happened to find them in.

The cost is a bit more scaffolding (`.codex-plugin/plugin.json`, `.claude-plugin/plugin.json`, `marketplace.json`). The payoff is that a plugin reads as a *thing* with a shape, instead of a cluster of skills you happen to have installed.

This isn't a replacement for `npx skills`, skillfish, or host-native extension mechanisms. They're still useful when you just want to grab one skill quickly. Plugins are for tools that work as a system.

## License

[MIT](LICENSE)
