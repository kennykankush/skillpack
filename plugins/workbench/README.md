# workbench

A dev workbench plugin for Claude Code. Research workflows, skill recommendations, conversation memory capture, and skill lifecycle management — all under `/workbench:`.

## Install

```
/plugin install workbench@kennykankush-skillpack
```

(Requires the `kennykankush-skillpack` marketplace added first — see [parent README](../../README.md).)

## What's in it

- **research-report** — Run a deep research dive on any topic. Produces a polished Quarto HTML report (`/workbench:research <topic>`) or a quick chat scan with no files (`/workbench:scan <topic>`).
- **skill-advisor** — Recommend which of your installed skills fits the task at hand. Read-only.
- **memory-scriber** — Capture a conversation's essence into a memory file at the end of substantial sessions.
- **skill-manager** *(agent)* — Manage the full lifecycle of Claude Code skills across plugins, npx, and skillfish. Discover, install, migrate, audit.

## Slash commands

- `/workbench:research <topic>` — Full research pipeline. Writes `notes.md` + `report.html` into `research/<umbrella>/<title>/`.
- `/workbench:scan <topic>` — Quick research scan. Replies inline with structured findings. No files.

## Convergence rule

Research output always lands as exactly two files:

```
research/<umbrella>/<title>/
  notes.md          ← raw consolidated findings
  report.html       ← rendered polished read
```

The `.qmd` source and Quarto cache live in a hidden `.build/` subdirectory. No file proliferation.

## Dependencies

- **Quarto** — auto-installed to `~/.local/share/quarto/` on first use of the research workflow. No sudo.

## License

[MIT](../../LICENSE)
