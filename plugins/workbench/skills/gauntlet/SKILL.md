---
name: gauntlet
description: >-
  Run a realistic user journey end to end and sweep-test the real subsystems behind it.
  Triage the whole journey, then test the risky stations with varied inputs, volume,
  and independent verification in an isolated reversible environment. Retain useful
  findings and reproductions; separate observed behavior from inferred user experience.
  Use when the user says gauntlet this flow, sweep-test the pipeline, simulate a user and
  stress the machinery, is X sound front to back, or run the gauntlet on a journey.
---

# Gauntlet — Run the System Through Its Trials

A diner orders, pays, eats, and leaves satisfied. That is the surface — the real user
experience, the happy path. Gauntlet's job is what happens *underneath*: the moment the
diner pays, you slip behind the counter and sweep-test the entire payment machine — not
"did this one card charge," but every branch of it (decline, double-tap, refund, partial,
wrong currency, retry), under volume, all entered from the **exact real state the order
left the system in.**

So gauntlet runs two layers at once. A realistic **user journey is the spine** — it
decides which subsystems get hit, in what order, and from what un-mocked state. And at
each action, a **deep sweep of the real subsystem behind it** — proving the machinery is
sound, not just that the click worked. The diner leaving satisfied means *both*: the
journey completed for them, and every station their actions touched came back clean.

It is the action-twin of the family's study skills. `devour` maps a codebase to
understand it; `bedrock` runs code to ground a claim in reality; **gauntlet drives a whole
stateful system's lifecycle as god and user at once, then adversarially verifies the
truth it computes.** It borrows `devour`'s discovery to find the levers and `scour`'s
"falsify, don't confirm" stance to pull the trigger. Its live twin is `hats:birdwatch`:
the same spine and stations, but a person drives and the agent keeps its hands off. Hand
a station to birdwatch when how it *feels* needs a real person; take a hot station back
from birdwatch when it needs a full sweep.

Lineage, so it isn't hand-waving: a fusion of **deterministic simulation testing**
(FoundationDB/Antithesis — drive the world, assert invariants), **agent-based
playtesting** (actors play through to break it), **synthetic user-journey testing** (the
realistic spine), and the **test-oracle problem** (property-based / metamorphic
independent verification). These are the bones — draw on one when a skeptic needs convincing, but don't lecture from them at runtime.

## Activation

Use this skill when the user asks for any of these:

- "gauntlet this flow" / "run the gauntlet on `<payments|scoring|onboarding>`"
- "sweep-test the whole pipeline / journey end to end"
- "simulate a user and stress the machinery behind each step"
- "is `<X>` sound from front to back?" / "god + user sweep"
- any moment they want a system *driven and proven*, not just smoke-tested — the whole
  chain from first input to satisfied end-user, with the engines underneath actually
  verified.

Gauntlet is an adversarial, in-flow, *reversible* proving run. For where it should hand
off or decline, see the next section.

## When NOT to fire

Hand off, don't force it:

- **Mapping to understand** → `devour`. **Resolving one consequential assumption** →
  `probe` or a direct check. **Structural auditing** → `bedrock`. **Checking how the world
  does it** → `scour`. **Writing a routine test suite** → normal unit/E2E work. A gauntlet
  can retain reproducible cases discovered during its sweep without becoming a test-suite project.

Decline outright (or build the missing scaffolding *only with explicit consent*):

- **It can't be isolated or reversed** — no sandbox/sim mode, no snapshot, only a live
  prod / real-money / real-user system. Never sweep what you can't undo.
- **No independent oracle is obtainable** by any of the four types — you can drive the
  system but cannot check the truth. You may still surface crashes, but say plainly *"this
  was a load test, not a proof"*; never imply verification you didn't do.

## The Constitution — four non-negotiables

1. **You are a suspicious customer, not an auditor.** Assume there is a flawed road until
   you have walked it and proven it safe. Hunt the flaw; do not confirm compliance.
2. **Never trust a subsystem's self-report.** Independently recompute the truth. The
   oracle is the heart — *without* an independent check, a run is just a load test, and it
   must say exactly that rather than implying it proved anything.
3. **Safe, or it does not run.** Snapshot before, restore after, sandbox/sim isolation.
   Never touch production, real money, or real users. If the system cannot be isolated and
   reversed, gauntlet **refuses** — or builds the missing scaffolding, but only with the
   user's explicit consent.
4. **Rule out your own harness before crying wolf.** Every "failure" is classified
   as a confirmed defect, a harness artifact, or an unconfirmed result with the missing
   check named. A bug in the simulation rig is not a bug in the system.

## The kitchen's laws — invariants you actively assert

- **A chain breaks at the hand-offs, not the stations.** Trace the seams *between*
  subsystems; that is where state gets dropped. Most testing checks stations — gauntlet
  watches the gaps.
- **A busy station is not a working one.** Verify what came out the other side, never the
  activity or the status code.
- **A road safe 99 times is still broken.** Run journeys under volume; rare and
  probabilistic failures only surface at scale.
- **The diner's satisfaction is the only real metric.** Trace all the way to the end-user
  outcome *and* experience. An internally-perfect kitchen that serves a cold plate failed.

## The Loop

### Phase 0 — Frame & isolate
Confirm the system and the journey(s) to run. Flip to a sandbox/sim mode (or stand up an
isolated copy). **Snapshot** so every mutation is reversible. If you cannot isolate +
reverse, stop here per Constitution #3.

Read relevant existing intent, map, findings, and tests. Record the source revision,
dirty scope, test environment, and owned state to restore. Choose the existing home for
run evidence and announce retained artifacts. Restoration applies to the isolated test
state and owned temporary resources; it must preserve user changes and retained evidence.

### Phase 1 — Map the gauntlet
Discover the **simulation surface** (devour-style, but aimed only at simulability):

| What you need | What you hunt for |
|---|---|
| **Engine of progress** (advance the lifecycle) | a clock/time-travel, a cron/tick/worker, an event-completer, a state-machine transition |
| **Actor seeding** | seed scripts, factories, signup/create paths |
| **Computed truths** (the things to verify) | scoring / settlement / billing / ranking / derived-state functions |
| **Reversibility** | snapshot/restore, transactions, a throwaway DB/branch |
| **Isolation** | a sim/test/dry-run mode, or a sandbox env |

Then map the **journey** (the spine) and the **subsystem behind each touchpoint**. Output:
the gauntlet map.

### Phase 2 — Surface run (breadth + triage)
Walk the whole journey breadth-first, smoke each station, and as you go **score each
touchpoint by blast-radius and by what smells off.** The output is not "it works" — it is
a **risk-ranked hit-list** of which subsystems earn a deep sweep.

### Phase 3 — Deep sweep (depth on the triaged stations)
For each station on the hit-list: seed a **varied + adversarial population** (deliberately
include the boundary cases of the domain's rules), drive the real subsystem through
**breadth × volume** from the realistic state the journey produced, and **independently
verify** with the strongest oracle the subsystem affords (see toolkit). Degrade honestly.

### Phase 4 — Diary
Narrate **one actor's journey** to a `user.md`, labeled as an agent-driven or human-observed
run. Use the project's existing run-evidence directory, or `audit/gauntlet/<run-id>/`
with a unique date-and-scope identifier. Keep observed behavior separate from inferred
experience: "the spinner remained after the error" is an observation; "a buyer may tap
again" is an inference. First-person narration must not invent human feelings or feedback.
This record catches dead-ends and silent failures that a number-check can miss.

### Phase 5 — Classify & report
Tie every flaw to the **journey step → subsystem → oracle that caught it.** Classify
real-vs-artifact. State coverage **honestly**: which roads you walked, which you skipped,
and how strong the oracle was at each station.

For a confirmed defect, record the expected and actual behavior, the relevant command,
inputs or seed, environment, and evidence pointer. If a suspected problem cannot be
reproduced or the harness is not ruled out, keep it unconfirmed and name the missing check.
Do not force an uncertain result into a confirmed-bug or harness-artifact verdict.

### Phase 6 — Restore
Restore the isolated test state and release owned temporary resources. Verify cleanup;
never use a broad working-tree reset or revert concurrent user edits. Retained findings,
diary, and useful reproductions follow the next phase and are excluded from test-state cleanup.

### Phase 7 — Preserve the protection

- **Findings:** update the project's existing finding ledger, commonly `AUDIT.md`, using
  its IDs and conventions. Reuse an existing entry for the same defect and attach this
  run's evidence. With no ledger, keep findings beside the diary in `findings.md`; do not
  create a competing repo-wide ledger or imply a bedrock audit occurred.
- **Reproductions:** retain a small, self-contained case for each confirmed defect in
  the existing test/repro home. If bedrock's `audit/repros/` exists, use its convention;
  otherwise keep the case with this run. Include safe setup, inputs/seed, expected versus
  actual results, and cleanup. Do not retain the whole temporary sweep harness by default.
- **Regression tests:** reuse an existing test that already captures the defect. Where
  worthwhile and in scope, promote the minimal case into the normal suite. Keep unresolved
  cases in the repro area with their status; avoid breaking routine CI merely to store
  a known failing reproduction. A request to fix continues into separately authorized
  implementation, and a closed finding must cite the passing regression evidence.
- **Handoff:** report retained paths, open findings, and coverage. Follow
  [WORKFLOWS.md](../../WORKFLOWS.md) for already-authorized next work. For a standalone
  sweep, finish with its evidence. If the user requested chat-only or no retained files,
  honor that and provide repeatable commands and findings inline, noting the persistence limit.

Steerable intensity: default is *surface-all + auto-deep the top-N risky stations*.
This is what gauntlet's totality means: every station the journey touches gets at least a
surface pass, and depth goes where the surface pass shows risk. Deep-sweeping everything is
not the promise.
"deep sweep payments" jumps straight to Phase 3 on a named station. "just surface it" is
a fast Phase 2 confidence check.

## The Verification Toolkit — strongest oracle wins, degrade honestly

The independent check is the whole point, and it adapts to what the system gives you:

1. **Re-derive from the breakdown** — recompute the result from its own components.
   Strongest; use whenever a breakdown exists.
2. **Conservation / invariants** — money in = money out, ranks are a permutation, no
   negative balances, counts conserved. Works with zero formula knowledge.
3. **Shadow model** — a dumb independent reimplementation of the rule; diff it against the
   real one. Catches wiring bugs the real code shares with itself.
4. **Property assertions** — must-hold-regardless-of-formula: idempotent, monotonic,
   deterministic on replay.

Pick the strongest available and **name which you used and how strong it was.** "Verified
by invariants only, not full re-derivation" is an honest, useful verdict; silent
rubber-stamping is the one unforgivable failure.

## Host-Agnostic Contract

Use whatever the host exposes — shell, DB inspection, test runners, framework CLIs, web —
and never hardcode a tool by name. If the host cannot run code or mutate an isolated copy
of the system, gauntlet cannot run; say so plainly rather than faking a result.

## Output Format

```text
Gauntlet: <system> — <journey> | intensity: <surface | deep:<stations>>

Map: <engine of progress · actors · subsystems-per-touchpoint · snapshot · isolation>

Surface (hit-list, by risk):
- <station> — <blast-radius> · <smell> → DEEP / skip

Deep:
- <station> — <population> × <volume> | oracle: <re-derive|invariant|shadow|property> (<strength>)
  → <N/N reconciled> | <findings>

Findings:
- <ID; step → subsystem> · <confirmed bug | harness artifact | unconfirmed>
  <expected vs actual; repro/evidence; severity/blast-radius; independent check>

Diary: <path or inline — observed behavior and inferred experience labeled separately>
Retained: <ledger entries; repro/test paths; existing coverage reused>

Coverage: roads walked <…> | skipped <…> | weakest oracle <…>
Restored: <test state and owned resources; outstanding cleanup if any>
```

## Quality Gate

A run is good only if:

1. It was **isolated and reversed** — snapshot taken, restore done (or honestly flagged).
2. The journey was **realistic and un-mocked** — each subsystem entered from state the
   journey actually produced.
3. Deep stations were verified by a **real independent oracle**, and the verdict **names
   the oracle and its strength**. No oracle → labelled a load test, not a proof.
4. Every confirmed defect has the harness ruled out and a reproducible case. Unconfirmed
   findings say what remains unresolved; harness artifacts are labeled separately.
5. Coverage is stated **honestly** — what was swept, what wasn't, where the oracle was weak.
6. The diary distinguishes observations from inferred experience, and retained findings
   and repros have clear homes without duplicating the project's existing ledger.

If you could not get an independent oracle anywhere, say "I stressed it but could not
prove it" — that is the honest output, not a green check.

**Redo trigger:** if a confirmed defect lacks reproducible evidence, experience inference
is presented as observation, a deep verdict omits its oracle and limits, or owned test
state was not restored, correct the affected record or finish cleanup. If a check cannot
be completed, report that limit and downgrade the claim; never present a partial sweep
as a complete one or rerun the whole journey just to satisfy report formatting.

## What Not To Do

Gauntlet's own worst failure is **the impressive-but-hollow sweep** — a big, busy run that
*looks* exhaustive but never independently verified anything, or that cried wolf on its own
harness. Every rule below exists to prevent exactly that.

- Do not call it proven when you only checked that it didn't crash. That's a load test.
- Do not mock the subsystem under sweep — the realistic entry state is the whole point.
- Do not trust a status code, a log line, or the system's own number.
- Do not report a harness artifact as a system bug (rule out your own rig first).
- Do not run against anything you can't isolate and reverse.
- Do not skip the diary — the silent failure it catches is the one the numbers miss.
- Do not deep-sweep everything; let the surface pass earn the depth.
- Do not discard a useful reproduction during restore or overwrite an existing diary.
- Do not count inferred user frustration as observed human research.

## Worked instances — two, maximally different

These calibrate the *moves and the voice*. They are **not** the menu of allowed inputs.
Re-run the loop from scratch for whatever system you're handed; never default to a game or
a checkout because the examples did. The lesson lives in the *delta* between them — different
subject, different dominant oracle, the same five moves.

### Instance 1 — a fantasy-sports scoring engine (oracle: re-derive from breakdown)

The run that birthed this skill. A knockout fantasy + predictions product, swept R32 → Final:

- **Spine (journey):** a manager drafts a squad at R32, plays each round, makes transfers,
  rides the bracket to the Final — the real user arc.
- **Deep sweep, scoring engine:** 8 varied managers × 5 round-multipliers (×1 → ×3) ×
  advancement bonus × transfers × penalty shoot-outs, driven through the *real* lifecycle
  primitives (produce → eliminate → resolve → score). Oracle: **re-derive from breakdown** —
  every score recomputed from its components. **40/40 manager-rounds reconciled, 0 mismatches.**
- **Deep sweep, predictions engine:** 1,896 picks across 63 users re-scored against the
  played-out fixtures and reconciled by class. **0 mismatches** (exact=3 / outcome=1 / miss=0,
  constant per class — a property assertion).
- **Real bug caught:** the surface pass crashed at the scoring station — a missing DB
  migration the journey would have hit silently in normal use. *Hand-off, not station.*
- **Artifact correctly dismissed:** a bracket "zombie" (a team that lost but appeared to
  advance) traced to the harness re-rolling an already-resolved round, **not** a resolver
  bug. *Rule out your own rig.*
- **Diary truth:** the `user.md` surfaced what the reconcile could not — when scoring
  crashed, a real user would just see scores *silently fail to update*. The fix (loud alert
  on scorer failure) came from the diary, not the numbers.

### Instance 2 — an e-commerce checkout (oracle: conservation + idempotency)

Same five moves, a different planet — to prove the skill isn't about games:

- **Spine (journey):** browse → add to cart → checkout → pay → order confirmed → receipt.
  Each step leaves the next its *real* state (a cart actually built, never a mocked total).
- **Deep sweep, payment + inventory + order:** a varied + adversarial population (guest vs
  account, one item vs many, coupon, out-of-stock-mid-checkout, flaky-network double-tap,
  expired card, partial refund) driven through the *real* charge → reserve → fulfil path,
  under volume. Oracle: **conservation + idempotency** — amount charged = order total = Σ
  line items; stock decremented exactly once; a retried submit with the same idempotency
  key charges *once*; a refund returns *exactly* what was taken; no order without a charge,
  no charge without an order.
- **The flaw it hunts:** the double-tap-on-a-spinner that charges twice (the road safe 99
  times), and oversell at the cart→checkout hand-off when two buyers race the last unit
  (*chains break at the hand-offs*).
- **Diary truth:** the buyer saw a spinner, tapped Pay again, got charged twice with no
  error — the silent failure a balance-reconcile alone might miss until the chargeback.

Different subject (game vs commerce), different dominant oracle (re-derivation vs
conservation), identical loop. That delta *is* the skill.
