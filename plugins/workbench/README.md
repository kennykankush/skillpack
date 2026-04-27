# workbench

Everyday dev plugin under `/workbench:`. Three areas, four tools, one posture: opinionated, disciplined, no mess.

## Install

```
/plugin install workbench@kennykankush-skillpack
```

(Requires the `kennykankush-skillpack` marketplace added first — see [parent README](../../README.md).)

## What's in it

### Research

**`research-report`** — Deep research that converges to exactly two artifacts: `notes.md` (raw consolidated dump) and `report.html` (polished, Quarto-rendered). No scratch files. No emojis. Two modes off the same engine:

- `/workbench:research <topic>` — official: writes both files into `research/<umbrella>/<title>/`
- `/workbench:scan <topic>` — quick: structured findings inline, no files. Promotable to official.

Umbrella domains (`marketing`, `engineering`, `uiux`, `product`, etc.) are deliberate taxonomy — pick the closest match.

### Memory

**`memory-scriber`** — Captures what a colleague internalizes from a working session — how you think, what you care about, where you left off. Not a summary. Not minutes.

- The opening brief is sacred (verbatim user voice)
- The journey at the bottom is non-negotiable (chronological reconstruction)
- The middle is reflective, in your voice — not report categories
- Quote the user when their phrasing reveals something

### Skills (managing the toolkit itself)

A pair: one reads the toolkit, the other writes to it.

**`skill-advisor`** — Read-only matchmaker. Answers "which of my installed skills fits this task?" from your local index. Does not install. Does not browse. Ranks 2–5 candidates with one-line justifications, suggests where they fit in your workflow, and flags when a category is thin so you know to call `skill-manager`.

**`skill-manager` (agent)** — Lifecycle pipeline. Three install mechanisms (plugins, npx skills, skillfish) plus manual, each with their own namespacing, lock files, and cleanup quirks. Encodes which mechanism to use and the gotchas of each — orphan folders left by `npx skills remove`, marketplace-name lookup, cross-mechanism collision checks. Always proposes before executing. Default scope is user/global. After every install, regenerates `~/.agents/CATEGORIES.md` so `skill-advisor` stays current.

Discover mode researches new skills from marketplaces and GitHub, then hands the install decision back.

## How they fit together

```
skill-advisor   → "what do I have for this?"
skill-manager   → "install what I'm missing"
memory-scriber  → "preserve what I learned today"
research-report → "go deep on something I want to know"
```

Personal infrastructure for working with Claude sustainably — not random utilities.

## Slash commands

- `/workbench:research <topic>` — full research pipeline
- `/workbench:scan <topic>` — quick research scan, no files

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

- **Quarto** — auto-installed to `~/.local/share/quarto/` on first use of `/workbench:research`. No sudo required.

## License

[MIT](../../LICENSE)
