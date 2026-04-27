# kennykankush-skillpack

My Claude Code loadout — a home for the plugins I actually use day-to-day. `workbench` is the first one in; more (frontend, etc.) coming as I extract them.

## Install

Add the marketplace once, then install whichever plugins you want:

```
/plugin marketplace add github.com/kennykankush/skillpack
/plugin install workbench@kennykankush-skillpack
/reload-plugins
```

## Plugins

### workbench

Everyday dev plugin — research workflows, skill recommendations, conversation memory capture, and skill lifecycle management. All under `/workbench:`.

- **research-report** — Run a deep research dive on any topic. Produces a polished Quarto HTML report (`/workbench:research <topic>`) or a quick chat scan with no files (`/workbench:scan <topic>`).
- **skill-advisor** — Recommend which of your installed skills fits the task at hand. Read-only.
- **memory-scriber** — Capture a conversation's essence into a memory file at the end of substantial sessions.
- **skill-manager** *(agent)* — Manage the full lifecycle of Claude Code skills across plugins, npx, and skillfish. Discover, install, migrate, audit.

See [`plugins/workbench/README.md`](plugins/workbench/README.md) for details.

### More coming

Frontend tooling and other plugins land here as I pull them out of my own setup.

## License

[MIT](LICENSE)
