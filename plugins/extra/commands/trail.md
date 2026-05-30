---
description: Reconstruct a day-by-day work trail from Codex and Claude conversation evidence.
argument-hint: <date range / vault / source hint>
---

Use the `trail-scriber` workflow for: $ARGUMENTS

Run the reconstruction as defined in `skills/trail-scriber/SKILL.md`:

1. Determine the mode: normal date/range extraction, or catch-up mode when the user says `catch-up`, `backfill`, `scan from last trail point`, or `procrastinate`.
2. Establish the date range, output root / target vault, and evidence sources.
3. Build an evidence map from Codex sessions, Claude transcripts, Claude history breadcrumbs, and any provided exports.
4. Read the user's messages day by day; use assistant messages only when needed for ambiguity, tool results, or provenance.
5. Discern agendas from intent, repo context, corrections, and agent provenance, not keyword matching alone.
6. Write or update day, agenda, domain, conversation, and month/no-evidence notes under the resolved output root using the existing vault style.
7. Validate coverage, links, whitespace, and secret hygiene before calling the trail complete.

Keep the output chronological, plain, and evidence-backed.
