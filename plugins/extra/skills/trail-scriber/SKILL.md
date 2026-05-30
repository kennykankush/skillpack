---
name: trail-scriber
description: Reconstruct day-by-day work trails from Codex and Claude conversation evidence into a durable agenda/domain graph. Use when the user asks to log what they did across dates, scan conversation history, update an Obsidian-style trail, or infer agendas from user messages.
---

# Trail Scriber - Day-by-Day Conversation Trail Reconstruction

## When to use

Use this when the user asks for any version of:

- "go through my Codex and Claude conversations and tell me what I did"
- "update my what-I-did-today list"
- "do May 14 / May 13 / this week day by day"
- "immortalise agendas", "make a trail", or "make the Obsidian graph intuitive"
- "read the user messages and get the vibe"
- "figure out what agenda this belonged to even if the folder was wrong"

This skill is for reconstruction from evidence, not generic summarization.

## What you are doing

You are turning scattered agent conversations into a durable work trail:

- days show what happened on a calendar date
- agendas show the actual workstreams
- domains show bigger life/project areas
- conversation/source notes preserve where the evidence came from
- month notes explain silent spans instead of inventing activity

The work is interpretive. Tools can locate candidate conversations, dates, roots, and session ids, but they must not replace judgment.

## Core posture

Read like a colleague reconstructing a workday from traces, not like a keyword classifier.

Prefer the user's messages. Assistant answers are optional evidence: read them only when the user's message is ambiguous, when a tool result is needed to confirm what happened, or when provenance matters.

Do not lazily assign domains by hard-coded keyword rules. Keywords may help triage candidates, but the final agenda/domain call must come from the conversation's intent, repository context, date context, and follow-up corrections.

## Inputs to establish

Before deep extraction, identify:

- date range, using the user's local timezone when available
- output root / target vault for notes
- evidence sources: Codex session files, Claude project transcripts, Claude history breadcrumbs, todo breadcrumbs, or any exported conversation files
- existing note topology: `days/`, `agendas/`, `domains/`, `conversations/`, `months/`, `event-ledger.md`, `README.md`
- whether the user wants commit checkpoints

If the user wants to discuss structure first, pause extraction and reason about topology before writing.

## Modes and invocation

The core behavior is host-agnostic. Codex skills, Claude commands, shell wrappers, and future scheduled runners should all resolve into one of these modes.

### Normal mode

Use normal mode when the user gives an explicit date or date range.

Examples:

- Codex: `$extra:trail-scriber May 14 day by day`
- Claude Code: `/extra:trail May 14 day by day`
- Natural language: `Use trail-scriber to do May 14 day by day.`

Normal mode should not infer a backlog from state unless the user asks for it.

### Catch-up mode

Use catch-up mode only when the user explicitly says:

- `catch-up`
- `catch up`
- `backfill from last scan`
- `scan from last trail point`
- `procrastinate`

`procrastinate` is an alias for catch-up mode. It is a friendly invocation word, not a separate workflow.

Examples:

- Codex: `$extra:trail-scriber catch-up`
- Codex: `$extra:trail-scriber procrastinate`
- Claude Code: `/extra:trail catch-up`
- Claude Code: `/extra:procrastinate`
- Natural language: `Use trail-scriber procrastinate mode.`

In catch-up mode:

1. Resolve the output root.
2. Read `<output-root>/.trail-scriber/state.json` if it exists.
3. Find `last_scanned_through_date`.
4. Compare it to today's date in the user's local timezone.
5. Build a candidate range from the day after `last_scanned_through_date` through today.
6. Scan and write day by day using the normal extraction method.
7. Update state only after validation succeeds.

If no state file exists, do not guess an unbounded backlog. Ask for a starting date, or use the explicit date/range supplied in the same request.

State file shape:

```json
{
  "schema": 1,
  "last_scanned_through_date": "2026-05-17",
  "last_successful_run_at": "2026-05-18T03:10:00+08:00",
  "last_mode": "catch-up"
}
```

## Output root resolution

Always establish one output root before writing notes. Do not write trail notes outside that root.

Resolve the output root in this order:

1. The user's explicit instruction in the current conversation.
2. `TRAIL_SCRIBER_OUTPUT_ROOT` from the environment.
3. `~/.config/trail-scriber/config.toml` with:

```toml
output_root = "$HOME/dev/hadi/trail"
```

4. The current repo or working directory, but only if it already looks like a trail vault with directories such as `days/`, `agendas/`, `domains/`, `conversations/`, or `months/`.
5. Ask the user for the output root.

Treat public plugin docs as examples only. Do not hardcode a private absolute path into the skill itself.

## Extraction method

### 1. Build an evidence map

Use commands only to create a map of candidate material:

- local date
- source host: Codex, Claude, or other
- session/conversation id
- project root or cwd
- first user prompt
- rough title if present
- transcript path or breadcrumb path

Do not generate final summaries directly from command output. The map is a reading queue.

### 2. Read day by day

For each date, read the relevant user messages in chronological clusters. If a conversation spans multiple dates, split the evidence by date and link the same source note to multiple days only when both dates have real user activity.

Dates are not agenda identity. A three-day conversation can contain one agenda, several agendas, or one agenda that shifts into another. Decide from the user's intent.

### 3. Discern the agenda

When assigning the workstream, weigh:

- what the user was trying to accomplish
- what repo/folder was active
- whether the active folder was wrong or incidental
- whether the work was done by the user, Codex, Claude, or spawned agents
- whether the thread changed topic halfway
- whether the work was research, implementation, hardening, UI polish, infra, writing, or triage
- how the user corrected the taxonomy later

If confidence is weak, say so in the note instead of forcing certainty.

### 4. Write the notes

Use the existing vault style under the resolved output root when present. Default topology:

```text
<output-root>/days/YYYY-MM-DD.md
<output-root>/agendas/<agenda-slug>.md
<output-root>/domains/<DOMAIN-NAME>.md
<output-root>/conversations/<host-or-breadcrumb-id>-<short-slug>.md
<output-root>/months/YYYY-MM.md
<output-root>/event-ledger.md
<output-root>/README.md
```

Day notes should answer, plainly:

- what happened that day
- which agendas moved
- what was only research/planning
- what was implemented, committed, pushed, or left local when known
- what was agent-led versus user-directed
- what evidence backs the reconstruction

Agenda notes should gather repeated work across days without becoming a dump of every link.

Domain notes should stay higher-level. They explain the bigger shape, not every task.

Conversation notes should preserve source identity and enough context to re-find the raw trace without leaking secrets.

### 5. Keep the graph readable

Link for meaning, not maximum edge count.

Use links that help navigation:

- day -> agenda
- agenda -> domain
- conversation -> day and agenda
- month -> covered days or silent-span note

Avoid linking every note to every other note. Dense graphs become unusable even when every individual link is technically true.

### 6. Handle no-evidence periods

If a date or month has no local evidence, do not invent work. Add a quiet no-evidence note only when it helps the continuity of the trail.

Example posture:

```markdown
No local Codex/Claude evidence found for this month in the available logs.
This is a coverage marker, not proof that no work happened.
```

## Source-specific guidance

### Codex

Codex sessions usually keep richer local transcripts. Use session paths and ids as source anchors. Prefer local date from the user's timezone, not just UTC path segments, when exact day boundaries matter.

### Claude

Claude may prune heavy project transcripts. If only `history.jsonl`, todo files, or other breadcrumbs remain, treat them as lower-fidelity evidence. It is valid to create notes from breadcrumbs, but label the confidence and do not pretend a full transcript was available.

### Mixed-host days

When Codex and Claude both touched the same agenda, preserve host provenance. The question is not "which agent owns the agenda"; it is "what did the user orchestrate, and through which tools?"

## Secret hygiene

Never copy raw secrets from transcripts into trail notes.

Redact or generalize:

- API keys
- bearer tokens
- database URLs
- mnemonic or seed phrases
- private keys
- app secrets
- webhook secrets
- personal access tokens

Write "API key setup", "database URL", "wallet seed material", or "provider credentials" instead of the secret value.

Run a focused secret scan before committing if raw conversation material was read.

## Validation

Before calling the trail done:

- check that every evidence date in scope has a day note or an explicit no-evidence marker
- check wiki links or Markdown links if the vault uses them
- run `git diff --check`
- run a secret-pattern scan over new/edited notes
- inspect `git status --short` and separate your changes from unrelated dirty files
- commit only when the user asked for commits or when the workflow already established checkpoint commits

## Output style

Be plain and chronological. Do not over-formalize the user's life into corporate categories.

Good language:

- "This was a Fantopy watcher/orchestration day."
- "The folder points at SSH, but the actual agenda was Finance Ledger hardening."
- "This looks agent-led: the user was mostly steering and checking provenance."
- "Confidence is medium because only Claude history breadcrumbs survived."

Bad language:

- "Based on keyword matching, this is DOMAIN_RULES item 38."
- "No evidence means no work happened."
- "This conversation belongs to one agenda because it lasted three days."
- "The graph should link every possible related note."

## Naming convention

Call this workflow **Trail Scriber**.

Display name: **Conversation Trail Scriber**.

The name pairs with `memory-scriber`: memory-scriber captures one session's durable residue; trail-scriber reconstructs a multi-day evidence trail across many sessions.
