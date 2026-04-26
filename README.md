# kennykankush-skillpack

A small skillpack of Claude Code utilities under one namespace.

## Install

```
/plugin marketplace add github.com/kennykankush/skillpack
/plugin install workbench@kennykankush-skillpack
/reload-plugins
```

## What's in it

### workbench

A dev workbench plugin grouping these utilities under `/workbench:`:

- **research-report** — Run a deep research dive on any topic. Produces a polished Quarto HTML report (`/workbench:research <topic>`) or a quick chat scan with no files (`/workbench:scan <topic>`).
- **skill-advisor** — Recommend which of your installed skills fits the task at hand. Read-only.
- **memory-scriber** — Capture a conversation's essence into a memory file at the end of substantial sessions.
- **skill-manager** *(agent)* — Manage the full lifecycle of Claude Code skills across plugins, npx, and skillfish. Discover, install, migrate, audit.

## About

Personal directory of Claude Code skills, packaged for `/plugin install`.

## License

[MIT](LICENSE)
