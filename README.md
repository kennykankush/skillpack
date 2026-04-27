# kennykankush-skillpack

My Claude Code loadout. The plugins I actually use day-to-day. One posture across all of them: deliberate, disciplined, no grab-bag.

## Install

Add the marketplace once, then install whichever plugins you want:

```
/plugin marketplace add github.com/kennykankush/skillpack
/plugin install workbench@kennykankush-skillpack
/reload-plugins
```

## What lives here

### workbench

The plugin that manages how I work with Claude itself: meta / everyday tooling. Three areas, four tools, all under `/workbench:`.

- **Research.** `research-report` runs deep dives that converge to exactly two files (`notes.md` + a Quarto-rendered `report.html`). Two modes off the same engine: official (writes files) and scan (inline only, promotable).
- **Memory.** `memory-scriber` captures session residue (the verbatim opening brief, a reflective middle in your voice, and a chronological journey at the bottom), so future sessions inherit the texture of past ones, not sterile minutes.
- **Skills (managing the toolkit itself).** `skill-advisor` reads your installed skill index and ranks 2 to 5 matches read-only. `skill-manager` (agent) handles the full lifecycle across three install mechanisms (plugins, npx skills, skillfish), always proposing before executing.

Full breakdown: [`plugins/workbench/README.md`](plugins/workbench/README.md)

### More coming

A plugin lands here once it's stuck in my own setup long enough that I trust it. Experiments stay in dotfiles.

Frontend tooling is the kind of thing that might land next. Or might not. No roadmap.

## The shape

```
workbench   → how I work with Claude (meta)
…           → other domains as they emerge
```

Each plugin is a vertical: a coherent slice of one workflow domain, not a random pile of skills. They share a posture but stay independent. Install only what you need.

## Why plugins, not flat skills

I've run three skill-install mechanisms in parallel (plugins from marketplaces, `npx skills`, skillfish). I wrote my own meta-agent (`skill-manager`) just to coordinate them. So I get the appeal of flat skills: one command, one file, no scaffolding. For a one-off skill, that's the right move.

The catch is heavy use. If you actually rely on skills as a primary way of working with Claude (and I do), the mess compounds. Skills sprawl across mechanisms. Names collide. Related tools end up scattered. Uninstalling leaves orphans. After living with all three, the lesson is simple: plugins are the only mechanism that actually compartmentalizes a workflow.

What plugins give you that flat skills don't:

1. **A namespace.** `/workbench:research` and `/workbench:scan` will never collide with anyone else's `research` or `scan`. Flat skills compete in one global pool. The fear of `/research` clashing with another skill is exactly why workbench got namespaced.
2. **A bundle.** Workbench has four tools that depend on each other. `skill-advisor` reads the index `skill-manager` regenerates. `memory-scriber` and `research-report` write into the same project tree. A plugin ships them as one unit. Flat skills install one at a time.
3. **Skills, agents, and slash commands together.** Plugins can bundle commands (`/workbench:research`), agents (`skill-manager`), skills, templates, and scripts under one roof. The `npx skills` mechanism only ships skills.
4. **Clean install and uninstall.** One command brings the vertical in, one takes it out. `npx skills remove` famously leaves orphan folders in `~/.agents/skills/` (it's why my `skill-manager` agent has dedicated cleanup logic for it). Plugins clean up properly.
5. **Versioning and a discoverable home.** Plugin marketplaces have semver, so you can pin, upgrade, or roll back the whole bundle. They're also browseable directories. Flat skills are scattered across whatever repos you happened to find them in.

The cost is a bit more scaffolding (`.claude-plugin/plugin.json`, `marketplace.json`). The payoff is that a plugin reads as a *thing* with a shape, instead of a cluster of skills you happen to have installed.

This isn't a replacement for `npx skills` or skillfish. They're still useful when you just want to grab one skill quickly. Plugins are for tools that work as a system.

## License

[MIT](LICENSE)
