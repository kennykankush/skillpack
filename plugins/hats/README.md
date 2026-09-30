# hats

Operating roles for the assistant you're already using.

A hat is a role the assistant you are talking to puts on and holds across a live session. These are not separate agents, app features or one-off prompts. Codex and Claude adapters stay thin, so the same role works in either host.

The pack was called `agents` until 0.2.0. It never contained sub-agents, and the name suggested it did.

## Skills

### `overseer`

The control tower for agent work. When agents build, test and ship, the user becomes the director and the overseer sits beside them.

Use it when you want the assistant to:

- get ready on the whole project first: rules, docs, roadmap, handovers, recent commits, each agent's latest state
- show a situation card with how fresh each fact is
- watch other coding agents and check their claims before repeating them
- relay your decisions to an agent, never approving anything you have not delegated in writing
- approve routine asks for you once you delegate them in writing, keeping a reserved list (spend, publishing, your own hands, security posture, unrecoverable deletions, client data, scope) that always comes back to you
- show progress as a checkpoint bar, with planned against actual times and two forecasts (at the observed speed, and a cautious one), updated at every checkpoint
- keep a decision queue of what is waiting on you
- keep a clock-stamped watch log in the project, so the next overseer starts where this one stopped

### `birdwatch`

The live QA companion, and gauntlet's live twin. You drive a flow; birdwatch stands behind the counter at every station and checks the screen against the API, the data and the logs.

Use it when you want the assistant to:

- watch logs, API responses, stored data, browser state, branch state, PRs and issues while you test
- keep a running discrepancy and experience ledger in your words
- keep observed, user-reported and inferred evidence apart
- hand a suspicious station to `workbench:gauntlet` for a full sweep, with your go
- avoid destructive actions unless explicitly asked

### `autoreview`

Runs a structured closeout and code-review pass against local changes, branch diffs or explicit commits.

Use it when you want the agent to:

- run a second-model review before final, commit, PR or ship
- pick the right review target instead of forcing a dirty-work review
- verify each accepted finding against the real code path
- apply only narrow fixes, then rerun focused tests and review
- stop when the bundled helper exits cleanly with no actionable findings

The workflow vendors OpenClaw's `autoreview` skill into this pack. Autoreview is a finite closeout workflow rather than a long-held role; it lives here because it is an operating posture the assistant takes on, not a study or build workflow.

## Invocation

Codex:

```text
$hats:overseer watch the agents on this repo and keep me briefed
$hats:birdwatch while I test this checkout flow
$hats:autoreview this branch against the PR base
```

Claude Code:

```text
/plugin install hats@kennykankush-skillpack
/hats:overseer watch the agents on this repo and keep me briefed
/hats:birdwatch while I test this checkout flow
/hats:autoreview --mode commit --commit HEAD
```

Natural language also works:

```text
Oversee the other agents and tell me whether their work is valid.
Use birdwatch while I sweep the signup lifecycle.
Run autoreview before we ship this patch.
```

## Boundaries

Overseer approves nothing. It relays only the user's own decisions, steps back when the user talks to an agent directly, never does the watched agent's work, and sets its information boundaries before studying the project.

Birdwatch observes first. It can run read-only checks, capture evidence and write a log when asked. It does not reset data, advance simulators, switch branches, change records, file issues or push commits unless the user explicitly asks for that action.

Autoreview is advisory. It can run the bundled helper, inspect findings and apply targeted fixes when asked to close them out. It should not push, merge or override the chosen review engine or model unless explicitly instructed.
