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
