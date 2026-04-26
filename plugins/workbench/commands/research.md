---
description: Run a deep research dive — produces a polished Quarto HTML report and consolidated notes.md.
argument-hint: <topic description>
---

Invoke the `research-report` skill in **official mode** for the topic: $ARGUMENTS

Run the full pipeline as defined in the skill's SKILL.md:

1. Bootstrap Quarto if needed (`scripts/bootstrap.sh`)
2. Pick the umbrella domain from the skill's list — ask the user if ambiguous
3. Slugify the title (kebab-case)
4. Plan source coverage based on the topic
5. State the plan in 2–3 sentences, then proceed
6. Research with maximum surface area
7. Run `scripts/new.sh <umbrella> <slug>` to scaffold
8. Write `notes.md` with one section per source
9. Synthesize `.build/report.qmd` using the visual primitives in the template
10. Run `scripts/render.sh <umbrella> <slug>` to render and open

End state: exactly two files at top level of the topic folder — `notes.md` and `report.html`. Source `.qmd` lives in `.build/` (hidden).

Follow all design rules from SKILL.md: no emojis, declarative tone, badges/bar-chart/mermaid for visuals, tables for comparison data.
