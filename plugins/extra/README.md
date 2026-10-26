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

It ships **`CONTRIBUTIONS.md` + `REVIEW.md` + `contributions-evidence/`, in three deliberate
registers**, because they answer different questions and one voice cannot do all three jobs
(the files are named for what they are, never for the skill):

- `CONTRIBUTIONS.md` - the ledger, in the **evidentiary register**: audit-report voice, claim
  followed by receipt, attribution tiers on the face of the document, no adjective that
  cannot be sourced, gaps disclosed rather than smoothed. Five layers: Verdict, Chapters,
  Total Ledger, Tally, Skills/Roles/Words. Built so a hostile reader can walk every number
  back to a file and fail to catch you out. Laying down that surface area is a deliverable
  in its own right, not scaffolding for the essay.
- `REVIEW.md` - the essay, in **plain English**: where contemporaneous observation from
  every form of conversation and record lands as a portrait of a person rather than a list
  of outputs.
- `contributions-evidence/` - the sweeps, in the **harvest register**: field reports, dated
  tables, a source ref per row, verbatim texture, and honest sections on what could not be
  found. The working papers that make the ledger checkable rather than merely assertive. An assessment: the arc, the discretionary record and its pattern,
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

### `cap-video-editor`

Turns existing screen recordings into narrated demos in Cap Studio. It covers footage study, scripts that explain purpose and results, narration fitted around skipped loading, local Qwen voice generation, fixed manual zooms, subtitles, and verified exports.

Use it to study a recording before writing, continue an existing edit, replace only an opening, add zooms without cursor tracking, or caption and export the current project. It preserves the user's latest cuts, imported audio, music, zooms, and caption style.

The main rule is to explain the bigger picture while anchoring the narration to visible evidence. It includes separate greeting renders with a measured pause, section-level audio fitting, source/output caption mapping, checks for low-magnification zoom wobble, and the difference between an export resolution setting and the encoded canvas. AI enhancement stays an optional comparison experiment; distorted text or numbers fail that experiment.

The skill includes a local sampling helper, operational references, and two worked instances: a software demonstration with loading gaps and a drawing lesson that retains its instructor's narration. It supports Codex and Claude without private paths or a mandatory synthesis provider.

```text
$extra:cap-video-editor study these recordings and make a synced narrated demo
/extra:cap-video-editor add captions to this Cap project and export 1080p60
```

Full workflow: [`cap-video-editor/SKILL.md`](skills/cap-video-editor/SKILL.md).

## Trail Scriber modes

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
$extra:cap-video-editor
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

For recording edits, use `/extra:cap-video-editor` or invoke the skill naturally. The command is a thin adapter to the same workflow.
