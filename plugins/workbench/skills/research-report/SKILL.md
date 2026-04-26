---
name: research-report
description: Run a deep research dive on any topic and either produce a polished Quarto HTML report (official mode — files written to research/<umbrella>/<title>/) or reply with structured findings inline (scan mode — no files). Use when the user invokes /workbench:research or /workbench:scan, or says "research X for me", "do a deep dive on X", "give me a quick read on X", "what's the state of X", "scan X for me", "write up findings on X". Covers maximum surface area across web, Reddit, GitHub, ProductHunt, docs, papers, and any other available sources. Always converges output to exactly notes.md + report.html (official mode) or a structured chat reply (scan mode). Never proliferates files.
---

# research-report

Two-mode research workflow. Same engine, two output destinations.

## When to use

Trigger on:
- `/workbench:research <topic>` — official mode (files written, persistent)
- `/workbench:scan <topic>` — scan mode (chat reply only, ephemeral)
- Natural language: "research X", "deep dive on Y", "give me a quick read on Z", "scan W", "what's the state of V", "write up findings on U"

Skip when:
- Quick fact lookup → use WebSearch directly
- Single-link extraction → use WebFetch directly
- Code question about a known library → use docs lookup
- Anything where the answer is one paragraph → just answer inline

## The two modes

### Official mode (`/workbench:research`)

Full pipeline: research, write notes, synthesize report, render HTML, open in browser.

End state: exactly two files in `research/<umbrella>/<title>/`:
- `notes.md` — consolidated raw research dump (one file even if many sources covered)
- `report.html` — polished, designed, render-ready

Hidden in `.build/` subdirectory: `report.qmd` source, quarto cache. Never visible to user.

### Scan mode (`/workbench:scan`)

No files. Replies in chat with structured markdown:

```markdown
## Key findings
- Bullet 1 (the punchline, not the setup)
- Bullet 2
- Bullet 3

## Sources
- [Link with one-liner of why it's relevant]
- [Link with one-liner of why it's relevant]

## Caveats / what I didn't check
- Honest one-liner about gaps

---
*Want me to save this as an official research report? Reply yes and I'll promote.*
```

If user confirms, transition to official mode using the same findings (write `notes.md`, synthesize `report.qmd`, render).

## The convergence rule (official mode)

Final state, no exceptions:

```
<project-root>/research/<umbrella>/<title>/
  notes.md          ← single consolidated raw dump
  report.html       ← rendered polished read
  .build/           ← hidden: qmd source, cache (gitignored)
```

Title = lowercase-kebab-case slug from the topic. "Replaydeck Reddit Positioning" → `replaydeck-reddit-positioning`.

If the project has a `.gitignore`, ensure `/research` is in it. Add it if missing.

## Umbrella domains

Pick the closest match. If two could fit, ask the user. If none fit, ask them to add a new one to this list.

| Umbrella | When to use |
|---|---|
| `marketing` | Competitive analysis, positioning, channel research, audience mapping, launch planning |
| `uiux` | UI patterns, design references, interaction studies, accessibility, design system research |
| `engineering` | Library evaluation, architecture choices, build tooling, infra, framework comparison |
| `product` | Feature scope, user needs, market sizing, pricing |
| `design` | Brand, visual systems, typography, iconography, motion |
| `ml` | Model evaluation, datasets, papers, benchmarks |
| `ops` | Deployment, monitoring, performance, scaling, oncall |
| `legal` | IP, licensing, ToS, compliance, GDPR |
| `competitive` | Direct competitor deep-dives across categories |
| `research-meta` | Fallback when no other category fits |

## Workflow

### Phase 0: Bootstrap (official mode only)

Run `scripts/bootstrap.sh` from this skill's directory. It checks for Quarto at `~/.local/share/quarto/bin/quarto` and installs if missing. Skip silently if already installed.

### Phase 1: Plan

1. Parse the topic from `$ARGUMENTS` or the user's message.
2. Pick the umbrella domain. Ask if ambiguous.
3. Slugify the title: lowercase, kebab-case, no special chars, ~3–6 words max.
4. Decide which sources to cover based on the topic. Examples:
   - Marketing/competitive → Reddit (if Reddit MCP available), web search, ProductHunt, IndieHackers, HackerNews
   - Engineering → GitHub, npm/PyPI/crates, package docs, web search
   - UIUX → web search, Mobbin/Dribbble references, design blogs
   - ML → arXiv, paperswithcode, GitHub, web search
   - Always include web search as a baseline
5. State the plan to the user in 2–3 sentences before starting (umbrella, slug, sources). Don't ask permission unless ambiguous — just proceed.

### Phase 2: Research (maximum surface area)

For each source, use the appropriate tool. Be exhaustive — depth before breadth. Capture:
- Primary findings (what you actually learned)
- Quotes with attribution
- Direct links to sources
- Numerical data where available (engagement, dates, counts)
- Caveats (rate limits hit, paywalls, sources missed)

If a Reddit MCP is available and the topic is Reddit-relevant: respect the 10 req/min rate limit (7-second pacing), sequential calls only, plan each call with a specific question.

When parallel reporter agents become available (Phase 2 of skill development), dispatch them here. For now, do the research inline.

### Phase 3: Consolidate (official mode)

Run `scripts/new.sh <umbrella> <slug>`. This:
1. Creates `research/<umbrella>/<slug>/.build/`
2. Copies templates (`_quarto.yml`, `styles.scss`, `report.qmd`) into `.build/`
3. Stubs `notes.md` at the top level
4. Adds `/research` to project `.gitignore` if missing

Fill in `notes.md` with the structure:

```markdown
# Research notes — <Topic Title>

> Raw data dump, blog format. Source for the polished report.

**Date:** YYYY-MM-DD
**Umbrella:** <umbrella>
**Sources covered:** <list>

---

## From <source 1>

[everything found from this source — links, quotes, raw data, screenshots referenced]

## From <source 2>

[same]

...
```

One section per source. Be generous with raw data — this is the source of truth for the report.

### Phase 4: Synthesize (official mode)

Edit `.build/report.qmd`. The template provides:
- Frontmatter (theme, layout, TOC config)
- Section scaffolds you fill in
- Visual primitives (badges, stat-grid, bar-chart, callouts)

Sections to populate, adapting to the topic:

1. **Report metadata strip** — window, sources, method, author
2. **Executive summary** — 3–5 sentence overview, then a `.callout-tip` with the one-line recommendation
3. **Headline numbers** — 3–4 stat cards in a `.stat-grid` (the most important numbers)
4. **Methodology** — short paragraph: window, sources, queries
5. **Findings sections** — one section per major finding theme. Use:
   - Markdown tables for comparison data
   - `.bar-chart` for engagement/score comparisons
   - Mermaid diagrams (`flowchart`, `gantt`, `graph`) for flows and timelines
   - `.callout-warning` / `.callout-important` for risks
   - `.callout-tip` / `.callout-note` for opportunities
   - `<span class="badge badge-...">` for status labels (avoid/wait/medium/post/clean/blocked)
6. **Recommendations / action plan** — concrete steps with timing
7. **Methodology notes** — `.methodology` block with detailed query log

Design rules:
- **No emojis.** Use text labels, badges, and styled spans only.
- Confident, declarative tone. Past tense for what was found, present for recommendations.
- Tables are first-class data viz. Use them generously.
- Mermaid for any graph/flow/timeline.
- Keep paragraphs tight; favor lists when there are >3 items.

### Phase 5: Render (official mode)

Run `scripts/render.sh <umbrella> <slug>`. This:
1. Runs `quarto render` on `.build/report.qmd`
2. Moves the output to `research/<umbrella>/<slug>/report.html` (top level of project)
3. Opens `report.html` in the default browser

If render fails, surface the error to the user with the relevant lines.

### Phase 6: Reply (scan mode only)

Skip Phases 3–5 entirely. Reply in chat with the structured markdown shown above. End with the promote prompt.

## Project root detection

Use the current working directory's git root if present:

```bash
git rev-parse --show-toplevel 2>/dev/null
```

Otherwise use the current directory. If neither makes sense (e.g., in `~`), ask the user where to save, or default to `~/research-reports/<umbrella>/<title>/`.

## Re-runs

If `research/<umbrella>/<slug>/` already exists, ask: "This research project exists. Update it (re-render with new findings appended) or replace (start fresh)?"

For updates: append to `notes.md` under a new dated section, update `report.qmd`, re-render.
For replaces: archive the old folder to `.archive-<timestamp>/` first, then start fresh.

## Templates and scripts

All assets live in this skill's directory:

```
skills/research-report/
  templates/
    _quarto.yml         ← Quarto config (theme, TOC, layout)
    styles.scss         ← Typography, badges, bar-chart, callouts
    report.qmd          ← Section scaffolding for the report
  scripts/
    bootstrap.sh        ← Verify/install Quarto
    new.sh              ← Scaffold a new research project folder
    render.sh           ← quarto render + open
```

## Scope guards

- **Never write files in scan mode** unless the user confirms promotion.
- **Never proliferate beyond `notes.md` + `report.html`** at the top level of the topic folder.
- **Never put files outside `research/<umbrella>/<title>/`** (no top-level scratch files).
- **Never commit research** — `/research` is gitignored automatically.
- **Always use existing umbrella domains** unless the user explicitly adds a new one.
