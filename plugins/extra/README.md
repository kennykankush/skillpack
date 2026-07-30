# extra

Small personal workflows that are useful enough to package but do not belong in Workbench.

Workbench stays focused on meta-work: research, memory, prompt translation, and skill/toolkit advice. `extra` is the separate shelf for durable workflows that are more specific, experimental, or personal.

## Skills

### `trail-scriber`

Reconstructs a day-by-day work trail from Codex and Claude conversation evidence.

Use it when you want to answer:

- what did I do on this date?
- what agendas did these conversations actually belong to?
- what should go into my Obsidian day, agenda, domain, and conversation notes?
- how do I avoid losing the essence by using only keyword/programmatic summaries?

The workflow is evidence-first and interpretive. Commands can locate candidate conversations, dates, roots, and session ids, but the final notes come from reading the user's messages and discerning the actual agenda.

### `testament`

The contribution sweep: reconstructs the evidence-backed totality of what someone did
over an era (an internship, a year, a project) and writes it as one layered,
critic-verified book with receipts.

Use it when you want to answer:

- what did I actually do, in totality, with no stones unturned?
- can I prove it - to a recruiter, a promo committee, or future me?
- which of it was certainly mine vs shipped through shared accounts vs produced by
  systems I built? (three-tier attribution honesty)
- what are the ready-to-paste, receipt-backed lines for my resume or case studies?

Three gears: **harvest** (a source census by artifact type, then one tracer per evidence
layer - version-control exports at full granularity, session diaries, day-trails, repo
atlases, media/marketing trees - plus a dedicated **character lane** over contemporaneous
sources; raw receipts exported so every number stays recomputable), **analysis** (master
timeline first, chapters derived bottom-up from the data, tallies from receipts, the
small-things catalog, the discretionary pass, the character synthesis), **presentation**
(two artifacts, see below). An adversarial critic pass in both directions - omissions AND
overclaims - is the quality gate; without it the output is a draft.

It ships **two documents**, because they answer different questions:

- `TESTAMENT.md` - the ledger. Five layers: Verdict, Chapters, Total Ledger, Tally,
  Skills/Roles/Words. Scannable and boring on purpose; read by someone verifying a claim.
- `REVIEW.md` - the essay. An assessment: the arc, the discretionary record and its pattern,
  how the person works (including a testimony section drawn from contemporaneous sources),
  hard skills in honest bands, industry-ladder leveling, the delta from start to end, real
  criticism with fixes, prepared answers to the hard questions, the counterfactual, and
  positioning. Read by the subject, or by them preparing for an interview.

The character lane is the part people skip and the part that makes the rest mean anything:
contributions come out of how a person thinks, so the sweep mines contemporaneous
observation (memory-scriber reflective sections, work journals, retros) for recurring
traits, taste-as-specification, verbatim quotes including the unflattering ones, and honest
notes. Testament is the withdrawal against everything `memory-scriber` and `trail-scriber`
deposited.

It degrades gracefully: on a machine without those vaults, the census simply finds fewer
layers and the output says so.

```text
/extra:testament fantopy internship
$extra:testament 2026
```

## Modes

Normal mode handles an explicit date or range:

```text
$extra:trail-scriber May 14 day by day
/extra:trail May 14 day by day
```

Catch-up mode scans from the last successful trail point through today:

```text
$extra:trail-scriber catch-up
/extra:trail catch-up
```

`procrastinate` is a friendly alias for catch-up mode:

```text
$extra:trail-scriber procrastinate
/extra:procrastinate
```

The alias is intentionally thin. It invokes the same host-agnostic catch-up behavior defined in the skill.

## Output root

`trail-scriber` writes into one resolved output root. It checks, in order:

1. an explicit path from the current request
2. `TRAIL_SCRIBER_OUTPUT_ROOT`
3. `~/.config/trail-scriber/config.toml`
4. the current repo, only if it already looks like a trail vault
5. a direct question to the user

Local config example:

```toml
output_root = "$HOME/dev/hadi/trail"
```

That path is intentionally an example. Keep private absolute vault paths in local config, not in the public plugin.

## Invocation

Codex:

```text
$extra:trail-scriber
```

Claude Code:

```text
/plugin install extra@kennykankush-skillpack
```

Then invoke the command or skill naturally:

```text
/extra:trail May 14 day by day
```

or

```text
Use trail-scriber to do May 14 day by day.
```

Catch up from the last scanned trail point:

```text
/extra:procrastinate
```
