# workbench

Everyday agent workbench. Four areas, five tools, one posture: opinionated, disciplined, no mess.

The workflow layer is meant to be portable. Codex, Claude Code, and future hosts can expose different invocation surfaces, but the research, memory, prompt translation, and skill-advice behaviors should remain the same.

## Install

### Codex

From the `skillpack` repo:

```
codex plugin marketplace add .
```

Restart Codex, open `/plugins`, install `workbench`, and start a new thread. Codex invokes the workflows as bundled skills: `$workbench:research-report`, `$workbench:skill-advisor`, `$workbench:memory-scriber`, and `$workbench:max-prompt`.

### Claude Code

```
/plugin install workbench@kennykankush-skillpack
```

(Requires the `kennykankush-skillpack` marketplace added first — see [parent README](../../README.md).)

## What's in it

### Research

**`research-report`** — Deep research that converges to exactly two artifacts: `notes.md` (raw consolidated dump) and `report.html` (polished, Quarto-rendered). No scratch files. No emojis. Two modes off the same engine:

- `/workbench:research <topic>` — official: writes both files into `research/<umbrella>/<title>/`
- `/workbench:scan <topic>` — quick: structured findings inline, no files. Promotable to official.
- Codex: invoke `$workbench:research-report` and say whether you want official mode or scan mode.

Umbrella domains (`marketing`, `engineering`, `uiux`, `product`, etc.) are deliberate taxonomy — pick the closest match.

### Memory

**`memory-scriber`** — Captures what a colleague internalizes from a working session — how you think, what you care about, where you left off. Not a summary. Not minutes.

- Codex writes native memory: `~/.codex/memories/MEMORY.md` and `~/.codex/memories/raw_memories.md`
- Claude Code writes project memory: `~/.claude/projects/<project-slug>/memory/MEMORY.md` plus a dated session file
- The active host decides the target; it does not mirror between hosts unless asked
- The opening brief is sacred (verbatim user voice)
- The journey at the bottom is non-negotiable (chronological reconstruction)
- The middle is reflective, in your voice — not report categories
- Quote the user when their phrasing reveals something

### Skills (managing the toolkit itself)

A pair: one reads the toolkit, the other writes to it.

**`skill-advisor`** — Read-only matchmaker. Answers "which of my installed skills fits this task?" from your local index. Does not install. Does not browse. Ranks 2–5 candidates with one-line justifications, suggests where they fit in your workflow, and flags when a category is thin so you know to call `skill-manager`.

**`skill-manager` (Claude agent, not yet a Codex plugin component)** — Lifecycle pipeline. Three install mechanisms (plugins, npx skills, skillfish) plus manual, each with their own namespacing, lock files, and cleanup quirks. Encodes which mechanism to use and the gotchas of each — orphan folders left by `npx skills remove`, marketplace-name lookup, cross-mechanism collision checks. Always proposes before executing. Default scope is user/global. After every install, regenerates `~/.agents/CATEGORIES.md` so `skill-advisor` stays current.

Discover mode researches new skills from marketplaces and GitHub, then hands the install decision back.

### Prompting

**`max-prompt`** — Turns fuzzy UI feedback, screenshots, taste, frustration, or half-formed product instinct into an implementation-ready prompt for a coding agent. It translates the feeling into mechanism, ownership, constraints, implementation direction, and verification behavior.

## How they fit together

```
skill-advisor   → "what do I have for this?"
skill-manager   → "install what I'm missing"
memory-scriber  → "preserve what I learned today"
research-report → "go deep on something I want to know"
max-prompt      → "turn this feeling into a buildable prompt"
```

Personal infrastructure for working with AI agents sustainably — not random utilities.

## Invocation Surfaces

### Codex

- `$workbench:research-report official <topic>` — full research pipeline
- `$workbench:research-report scan <topic>` — quick research scan, no files
- `$workbench:skill-advisor <task>` — recommend from the installed toolkit
- `$workbench:memory-scriber` — capture the current session
- `$workbench:max-prompt` — translate vague feedback into an implementation prompt

### Claude Code

- `/workbench:research <topic>` — full research pipeline
- `/workbench:scan <topic>` — quick research scan, no files

Claude Code also loads `skill-manager` as an agent. Codex uses bundled skills and natural language instead of custom plugin slash commands.

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

[MIT](../../LICENSE)
