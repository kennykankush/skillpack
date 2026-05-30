---
description: Catch up the conversation trail from the last successful Trail Scriber scan.
argument-hint: [optional start/end/date hint]
---

Invoke `trail-scriber` in catch-up mode.

`procrastinate` is an alias for Trail Scriber catch-up. It is not a separate workflow.

Run the same workflow as `/extra:trail catch-up`:

1. Resolve the output root.
2. Read `<output-root>/.trail-scriber/state.json`.
3. Use the day after `last_scanned_through_date` through today as the candidate range.
4. If no state file exists, ask for a starting date unless $ARGUMENTS provides one.
5. Read user messages day by day and discern agendas from intent, repo context, corrections, and agent provenance.
6. Write or update notes under the resolved output root.
7. Validate coverage, links, whitespace, and secret hygiene.
8. Update state only after validation succeeds.

If $ARGUMENTS includes a date or range, use it to constrain or seed the catch-up range.
