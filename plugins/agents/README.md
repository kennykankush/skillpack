# agents

Harness-agnostic agent operating modes.

`agents` is the pack for reusable roles: not app features, not research workflows, not one-off prompts. Each skill defines an operating posture an assistant can hold across a live session, with Codex and Claude adapters kept thin.

## Skills

### `autoreview`

Runs a structured closeout/code-review pass against local changes, branch diffs, or explicit commits.

Use it when you want the agent to:

- run a second-model review before final, commit, PR, or ship
- pick the right review target instead of forcing dirty-work review
- verify each accepted finding against the real code path
- apply only narrow fixes, then rerun focused tests and review
- stop when the bundled helper exits cleanly with no actionable findings

The workflow vendors OpenClaw's `autoreview` skill into the `agents` pack so Codex can invoke it as `$agents:autoreview` and Claude can invoke it through `/agents:autoreview`.

### `birdwatch`

Turns an assistant into a live watcher during app/product/dev work.

Use it when you want the agent to:

- watch logs, API responses, DB rows, browser state, branch state, PRs, and issues while you test
- keep a running discrepancy and experience ledger
- separate user-visible friction from backend/data bugs
- verify claims against live evidence instead of guessing
- avoid destructive actions unless explicitly asked

The workflow is intentionally harness-agnostic. Codex can invoke it as a skill, Claude can invoke it through `/agents:birdwatch`, and future runners can provide the same inputs: scope, evidence sources, output log, and allowed actions.

## Invocation

Codex:

```text
$agents:birdwatch while I test this checkout flow
$agents:autoreview this branch against the PR base
```

Claude Code:

```text
/plugin install agents@kennykankush-skillpack
/agents:birdwatch while I test this checkout flow
/agents:autoreview --mode commit --commit HEAD
```

Natural language also works:

```text
Use birdwatch while I sweep the predictions lifecycle.
Run autoreview before we ship this patch.
```

## Boundary

Autoreview is advisory. It can run the bundled helper, inspect findings, and apply targeted fixes when asked to close them out. It should not push, merge, or override the chosen review engine/model unless explicitly instructed.

Birdwatch observes first. It can run read-only checks, capture evidence, and write a log when asked. It does not reset databases, advance simulators, switch branches, mutate rows, file issues, or push commits unless the user explicitly asks for that action.
