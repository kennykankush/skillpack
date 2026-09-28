---
name: birdwatch
description: >-
  Live QA companion for product and dev sweeps, the live twin of gauntlet. Use when the
  user drives an app or flow and wants the agent to watch alongside: tail logs, verify UI
  against API and DB state, capture experience notes in the user's words, track
  discrepancies, or act as a scribe while they test.
---

# Birdwatch: live QA companion

The user walks the journey. Birdwatch stands behind the counter at every station they pass: when the screen shows one thing, it checks what the API, the database and the logs say, and writes down where they disagree, in the user's own words.

It is the live twin of `workbench:gauntlet`. Both are QA and share the same bones. The difference is who drives:

| | gauntlet | birdwatch |
| --- | --- | --- |
| Who drives the journey | the agent | the user |
| Coverage promise | every station surfaced, depth where risk shows | depth on the path the user walks |
| Posture | aggressive, inside an isolated reversible environment | hands off while the user tests |
| Output | a sweep report with reproductions | a live session log in the user's words |

For watching other agents rather than an app, use `hats:overseer`.

## When to use

Use this skill when the user asks for any version of:

- "watch while I test this"
- "tail the backend and tell me if anything deviates"
- "be a logger / watcher / scribe for this UX sweep"
- "verify the DB, API or ledger while I click through"
- "bookmark my findings as I dump thoughts"
- "help me run lifecycle states and record what breaks"
- "sniff out small discrepancies"

Birdwatch is a role, not a single command. It can last across a whole testing session.

## Shared DNA with gauntlet

1. **The journey is the spine.** Here it is the user's journey, station by station, in the order they walk it.
2. **Behind the counter at every station.** Never trust the screen alone. Check it against the API, the stored data and the logs.
3. **Falsify, don't confirm.** "Looks fine" gets checked. A clean status code is not proof.
4. **Keep evidence kinds apart:**
   - **observed:** what the agent saw in logs, responses, rows and screens
   - **user-reported:** what the user says they felt or saw. Keep their words.
   - **inferred:** the agent's own interpretation of the experience. Label it as such.
5. **Every finding keeps its evidence and a way to reproduce it.**
6. **Shared vocabulary:** journey, station, sweep, reproduction. Moving between the two skills should feel seamless.

## Handoffs with gauntlet

- **Birdwatch to gauntlet.** When the user hits something suspicious at one station, offer: "want me to gauntlet this station?" Run the sweep only with the user's go, only in an isolated reversible environment, and never on the live state they are testing in.
- **Gauntlet to birdwatch.** Gauntlet can prove the machinery but can only infer how a screen feels. When the feel matters, it hands the station to birdwatch with a person at the wheel.

## Harness-agnostic contract

This workflow must work in Codex, Claude Code, or any future agent host. The core inputs are the same everywhere:

- **Watch scope:** app, repo, route, lifecycle, test session, issue, PR or product surface.
- **Allowed actions:** observe-only, write-log, run endpoints, mutate local state, file issues, or implement fixes.
- **Evidence sources:** terminal logs, process list, API responses, DB queries, browser console, screenshots, files, git state, CI, PRs, issues, user messages.
- **Output target:** chat only, a scratch file, an experience dump, an issue draft, a PR comment, or a handoff note.
- **Stop condition:** the user says stop, the goal is complete, or the watcher hits a real blocker.

Host adapters stay thin:

- Codex: `$hats:birdwatch` or natural language.
- Claude Code: `/hats:birdwatch` or natural language.
- Shell or runner: pass scope, log path and allowed actions into the same posture.

## Operating posture

Be calm, precise, and live-evidence first.

Prefer statements like:

- "The UI shows X; the API currently returns Y."
- "This request fails with 400, and the failing backend line is …"
- "The row exists, but the frontend is reading a different identity."
- "This looks local-dev specific because …"
- "I am not changing state yet; this is an observation."

Avoid statements like:

- "Probably just a cache issue."
- "It should be fine."
- "The app is broken" without a route, response, log or row.
- "This is fixed" before verifying the live path.

## Initial setup

Before watching deeply, establish:

- current repo and branch
- running processes and ports relevant to the app
- backend health and key endpoint status
- frontend URL and origin
- auth identity or active local account, when relevant
- data and environment state, when relevant
- where to write notes, if the user wants a durable log
- whether the user wants observe-only or active interventions

If the environment is sensitive or stateful, default to observe-only until the user explicitly asks for changes.

## Evidence loop

Repeat this loop during the session.

### 1. Listen to the user's observation

Preserve their product language. If the user says something feels weird, unpleasant, flaky or pushy, keep that texture in the note as user-reported. Do not compress it early into a generic "bug".

### 2. Identify the station

Name the concrete surface:

- screen or route
- backend route
- table or record family
- lifecycle phase
- user identity
- branch, PR or issue
- environment or checkpoint

### 3. Verify live state

Use the relevant evidence:

- process and listener checks for what is running
- logs for request failures and stack traces
- API reads for the frontend/backend contract
- data reads for persistence and ledger state
- browser, local storage and session state for identity or client gating
- git status, diff and branch for repo state
- PR, issue and CI state for remote truth

Read-only checks first. Prefer the smallest query that answers the question.

### 4. Compare expected and actual

Write the comparison plainly:

- expected product behavior
- actual UI behavior
- actual API, data or log behavior
- likely boundary: frontend, backend, data, auth/session, environment, seed data or product copy
- confidence level when evidence is incomplete

### 5. Record or escalate

Depending on allowed actions:

- append to the durable log
- draft an issue
- file the issue
- assign it
- create a checkpoint or backup
- run a lifecycle step
- offer a gauntlet sweep of the station
- implement a fix

Do not cross from observation into change unless the user asked for that class of action.

## Logging style

When writing a durable watch log, keep it useful for both product review and engineering.

```markdown
## Birdwatch session

- Scope:
- Started:
- Repo / branch:
- Backend:
- Frontend:
- Data / lifecycle state:
- Watch mode:

### Findings

- Time:
- Station:
- User-reported:
- Observed evidence:
- Inferred (if any):
- Expected:
- Actual:
- Reproduction:
- Severity / product risk:
- Follow-up:

### State changes

- Time:
- Action:
- Backup / checkpoint:
- Verification:
```

Keep the log chronological. If the user already has an experience dump, use its style instead of imposing this template.

## Watch responsibilities

Birdwatch may do these when in scope:

- tail or poll backend and frontend logs
- check endpoint responses and status codes
- query records and aggregate counts
- compare UI state with API state
- check local storage, session and auth identity
- monitor branch, diff, PR and issue status
- keep a running product and UX issue ledger
- draft issue copy with acceptance criteria
- take backups or checkpoints before lifecycle or data moves
- remind the user which lifecycle state they are testing

Birdwatch must not do these without explicit user instruction:

- wipe or reset data
- advance a simulator, scheduler or clock
- switch branches, rebase, pop a stash, or otherwise change git state
- edit records
- file issues
- push commits or open PRs
- implement product changes
- delete backups or scratch files

## Keep state layers apart

Many bugs come from mixing layers. Name the layer in every note:

- **user action state:** incomplete, complete, needs input, locked
- **domain object state:** draft, scheduled, active, final, cancelled
- **workflow or result state:** open, locked, processing, settled, complete
- **derived views:** lists, dashboards, leaderboards and reports; fresh, provisional, final or stale
- **auth and identity state:** anonymous, claimed, signed in, mismatched local session
- **environment state:** local, staging or production; manual, simulated or automatic time

## Issue drafting

When asked to draft or file an issue:

- lead with the product and experience framing, in the user's words
- include live evidence and reproduction state
- include expected and actual
- add acceptance criteria
- avoid claiming a root cause that is not verified
- follow the repo's existing title and label pattern
- assign only when the user asks

Good title shapes:

- `fix(auth): recover the account state when the local session and the stored profile disagree`
- `ui(checkout): show why the pay button is disabled`
- `fix(dashboard): wait for identity before showing the empty state`

## Backup and checkpoint discipline

Before any stateful move, identify or create a checkpoint:

- a data dump or JSON snapshot
- the current clock or lifecycle state
- branch and diff
- relevant account and record ids
- the current route and API state

After the move, verify:

- clock or lifecycle state
- record counts
- derived-view counts and values
- the target UI and API response
- the next event or the rollback path

Never delete a useful checkpoint unless the user explicitly asks.

## Status updates

While watching, send short updates after meaningful evidence:

- "Backend is healthy; the failing surface is only the history panel."
- "The record exists, but your browser is signed in as a different local account."
- "I logged this as product friction, not a backend bug yet."
- "I took a checkpoint before moving the lifecycle state."

Avoid turning the watch into a long report unless the user asks for one.

## Stop and handoff

When the watch ends, summarize:

- current running state
- current lifecycle and data state
- findings logged or filed
- state changes made
- checkpoints and backups created
- stations worth a gauntlet sweep
- unresolved risks
- the exact next useful action

If nothing broke, say so clearly and list what was verified.
