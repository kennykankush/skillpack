---
name: gauntlet
description: Run a system through its trials. Drive a realistic, goal-driven user journey end-to-end as the spine, and at every action the user takes, sweep-test the REAL subsystem behind it — a surface pass (breadth across the whole journey that also triages each touchpoint into a risk-ranked hit-list) funnelling into a deep pass (depth on the risky stations: a varied + adversarial population, breadth × volume, independent verification). It proves both that the user's experience held AND that the machinery is sound. Skeptical flaw-hunting stance, safe and reversible. Use when the user says "gauntlet this flow/journey", "sweep-test the whole pipeline end to end", "simulate a user and stress the machinery behind each step", "is X sound front to back", "god+user sweep", or "run the gauntlet on payments/scoring/onboarding". A fusion of deterministic simulation testing, agent playtesting, synthetic user journeys, and the test-oracle problem — bedrock's bigger sibling.
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
"falsify, don't confirm" stance to pull the trigger.

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

- **Mapping to understand** (not prove) → `devour`. **Grounding one claim** by running one
  thing → `bedrock`. **Checking how the world does it** → `scour`. **Tests the user will
  keep** → a normal unit/E2E suite, not a one-shot reversible sweep.

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
   real-vs-artifact. A bug in the simulation rig is not a bug in the system.

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
Narrate **one actor's lived journey** to a `user.md` — first person, goal-driven. This is
the experience truth a number-check cannot see: dead-ends, silent failures, cold plates.

### Phase 5 — Classify & report
Tie every flaw to the **journey step → subsystem → oracle that caught it.** Classify
real-vs-artifact. State coverage **honestly**: which roads you walked, which you skipped,
and how strong the oracle was at each station.

### Phase 6 — Restore
Revert to the pre-gauntlet snapshot. Leave the system as you found it.

Steerable intensity: default is *surface-all + auto-deep the top-N risky stations*.
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
- <step → subsystem> · <REAL bug | artifact> · <severity/blast-radius> · <oracle that caught it>

Diary: <path to user.md — the experience truth, 1 line>

Coverage: roads walked <…> | skipped <…> | weakest oracle <…>
Restored: <yes/no>
```

## Quality Gate

A run is good only if:

1. It was **isolated and reversed** — snapshot taken, restore done (or honestly flagged).
2. The journey was **realistic and un-mocked** — each subsystem entered from state the
   journey actually produced.
3. Deep stations were verified by a **real independent oracle**, and the verdict **names
   the oracle and its strength**. No oracle → labelled a load test, not a proof.
4. Every finding is **classified real-vs-artifact**, with the harness ruled out.
5. Coverage is stated **honestly** — what was swept, what wasn't, where the oracle was weak.

If you could not get an independent oracle anywhere, say "I stressed it but could not
prove it" — that is the honest output, not a green check.

**Redo trigger:** if any finding shipped unclassified (real-vs-artifact), or any deep
station's verdict didn't name its oracle and strength, or the system wasn't restored —
the run isn't done. Go back and finish it; never present a partial sweep as a complete one.

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
