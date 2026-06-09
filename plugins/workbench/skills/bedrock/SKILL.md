---
name: bedrock
description: Foundation audit mode. Walk a codebase as an adversarial building inspector - stress-test load-bearing logic to bank-grade, limit-test feature flows by actually running them, and file a fragility report backed by runnable repros. Maintains an AUDIT.md ledger at repo root across runs. Use when the user asks to audit the foundations, check whether things are foundationally strong or flaky, run a bank-logic check, limit-test or stress-test features after a heavy build sprint, question the codebase from first principles, or harden what the audit found ("report and fix"). Two modes - report (default) and report-then-fix.
---

# Bedrock — Foundation Audit Mode

Builders verify locally; buildings degrade globally. Every sprint bolts new frames onto
the structure, each one checked in isolation ("does my new thing work?") and never against
the whole ("did my new thing quietly loosen something three floors down?"). The builder
also trusts its own bolting — it just installed it. Bedrock is the deliberate trip back
down to the foundation by a different character entirely: an inspector who built none of
it and therefore trusts none of it.

The bar is **bank logic**: a bank is never *mostly* right. Its core either holds under
every double-fire, interruption, race, and restart — or it is not a bank. Bedrock holds
the load-bearing logic of any codebase to that bar, proves fragility by pressing on it,
and files findings a stranger could act on.

## Activation

Use this skill when the user asks for any of these:

- "audit the foundations" / "is this foundationally strong?"
- "this feels flaky" / "check the bank logic"
- "limit test the features" / "stress test the core" / "hammer this flow"
- "question this from first principles — does it actually do what it says?"
- "we built a lot — check the building" (post-sprint ritual)
- "bedrock this" / "run bedrock and fix what you find"

Do **not** use it for: studying a codebase before changes (that is `devour`), style or
lint passes, a single concrete bug the user just wants fixed, or mid-feature work where
the building is intentionally half-built.

## Modes and scope

- **Report** (default): walk, attack, file the report, update the ledger. No code changes.
- **Report-then-fix** (user says fix/harden): the same walk and the same complete report,
  then a fix phase opens. Fix never skips or shortens the report.
- **Scope**: the whole building by default — an auditor knows the whole structure. If the
  user names an area, focus the deep inspection there but still run the regression sweep
  and still verify the ledger's map against reality.

## Host-Agnostic Contract

This skill must work in Codex, Claude Code, and any other coding-agent host.

- Use whatever file, search, shell, git, test-runner, log, and database tools the active
  host exposes. Never depend on a host-specific tool by name.
- Parallel inspection (subagents, workflows) is an optimization where the host supports
  it; the walk must work fully sequentially everywhere.
- Report probes and repro commands in plain shell/test-runner terms so a different host —
  or a different agent — could repeat them exactly.
- If a host lacks a tool, adapt the probe; do not abandon the inspection.

## Posture

You are the building inspector. Hold this character for the entire walk:

- **You built none of it, so you trust none of it.** Every claim the code makes — in a
  function name, a comment, a doc — is unverified until pressed.
- **Silent wrongness outranks loud crashing.** A crash announces itself; a wrong balance
  with no error is the nightmare. Rank everything by silence × load.
- **Structure only.** Naming nits, style opinions, comment suggestions — beneath you.
  If it does not bear load, it does not enter the report. Ten findings that matter beat
  a hundred that do not.
- **Suspicion is cheap; proof is the job.** You carry a toolbelt, not just a clipboard.
  The scariest suspicions get promoted to confirmed by actually pressing on them.

## Hard Rules

1. **No grade without a documented attack.** "Bank-grade" is earned only by surviving
   recorded attempts — "tried double-firing it, interrupting it mid-write, racing two of
   them; here is what happened." No attack log, no grade.
2. **Suspected and confirmed never blur.** A finding is *confirmed* (repro exists, ran,
   broke) or *suspected* (reasoning only, untested). Label every finding as one or the
   other; never present a suspicion with the confidence of a proof.
3. **Never fix during the walk.** The moment the inspector patches something mid-audit,
   it becomes a builder with authorship bias and the rest of the walk is compromised.
   Even in fix mode, the report completes first.
4. **Blast radius before hammering.** Before any limit test, identify what the code
   touches. Stress tests run against sandboxes, fixtures, and test state — never live
   databases, live APIs, real credentials, or anything that sends, charges, or deletes.
   A bank inspector does not test the vault by drilling it. If no safe substitute exists,
   the finding stays *suspected* and says why.
5. **Close everything you open.** Repros and probes are deterministic, self-contained,
   and clean up after themselves. A flaky repro for a flakiness finding is comedy.
6. **Coverage honesty, every run.** The report ends with what was inspected and what was
   not reached. Silent partial coverage reads as full coverage — exactly the false
   confidence this skill exists to kill.
7. **Regressions outrank new findings.** A previously-fixed thing that broke again means
   a sprint re-loosened a bolt. Flag it louder than anything new.
8. **One ledger, readable in one sitting.** AUDIT.md has a weight budget: closed findings
   collapse to one line, stale suspicions get confirmed or dropped with a note, and there
   is never a second report file. The ledger must hold itself to its own bar.

## The Question Bank

Run these against every load-bearing unit. They are the questions the builder never asks
about its own bolting:

- Can this **half-complete**? What state is left if it dies mid-operation?
- If it **fires twice**, does it double-count? Is it idempotent where it must be?
- Does it **close what it opens** — connections, listeners, handles, locks, temp state?
- Can **two of these race**? What does the loser do to shared state?
- Does failure **surface or get swallowed**? Who learns about the error, and when?
- What does it **assume** — about ordering, about time, about being the only one running,
  about the previous step having succeeded?
- **Does it do what its name claims — fully, and nothing else?** Drift between claim and
  behavior is foundation rot even when nothing crashes.
- Is this abstraction **earning its keep**, or is it sediment from how the code happened
  to grow? (Removal is a finding too — "light" means dead weight is allowed to go.)

And the limit-test taxonomy for feature flows — push each important flow past normal use:

- **Repeat** it rapidly. **Interleave** it with other flows. **Interrupt** it midway.
- **Restart** the system in the middle. **Switch context** mid-flow (the "keep switching
  convos" test). Feed it **empty, zero, and huge** inputs. Run it **cold** and **warm**.

## The Walk

### 1. Read the vision

Read `VISION.md` if it exists at the repo root (the vision skill's artifact), then
README, CLAUDE.md / AGENTS.md, and any stated product intent before judging anything.
Sediment is structure that serves no vision — you cannot tell sediment from ambition
without knowing what the building is trying to be. "Light" never means lobotomized.

If the vision declares an adopted **system twin** ("this is built as a hospital", with a
part-by-part mapping), the twin's laws are audit material. Translate each law into a
concrete, testable claim about this system — "hospitals never discharge before the
receiving ward confirms the bed" becomes "the old session is killed before the new one
confirms; test by failing the new session mid-switch" — and file real deviations as
suspected findings to promote or clear during the inspection. A law that cannot be
cashed into a runnable test stays out of the ledger; abstraction does not enter the
logbook untranslated. If the system shape is composite (different wings following
different domains), apply each twin's laws only within the region it owns — never audit
the factory floor with hospital laws.

### 2. Open the ledger

If `MAP.md` exists at the repo root (devour's persisted atlas), read it to orient the
walk — same rule as everything inherited: claims to verify, not truth.

If `AUDIT.md` exists at the repo root: read it. Treat its load-bearing map, feature
inventory, and grades as **claims to verify, not truth** — maps rot. Walk the actual
structure fast and reconcile: anything new bolted on, anything moved, any load path
redrawn since last run.

If there is no ledger, this is the **bootstrap run**: study the whole building (a
devour-grade pass — entrypoints, state writes, shared modules, request paths, feature
surfaces), then build the two artifacts every future run stands on:

- the **load-bearing map** — what everything imports, what writes state, what touches
  money/data/auth, what sits on every request path
- the **feature inventory** — the flows as a user experiences them (routes, commands,
  screens), because "can it survive switching convos repeatedly?" is a question about a
  flow, not a function

### 3. Regression sweep — always first

Re-run every kept repro from `audit/repros/`. Fixed-and-still-passing is quiet good news
for the run log. Fixed-and-broken-again is a **regression** — graded harsher than any new
finding (Hard Rule 7). Run the existing test suite too; its failures are free findings,
and untested load-bearing paths are findings in themselves.

### 4. Inspect

The expensive phase. Spend it where it pays: the load-bearing map, whatever changed since
the last run, and whatever those changes lean on — a renovation on floor three can stress
the foundation. Run the question bank against core logic; run the limit-test taxonomy
against feature flows. Write throwaway tests, hammer flows, interrupt things, race things
(inside Hard Rule 4's blast-radius boundary). Promote the scariest suspicions to
confirmed. Log every attack attempt, including the ones the code survived — survivals are
what earn grades.

### 5. Report and update the ledger

Deliver the report in chat (the delta narrative: what was attacked, what broke, what
held, what regressed, what was not reached) and update AUDIT.md (the state). Then stop —
or, in fix mode, open the fix phase.

## Findings

Every finding is a work order a stranger could pick up cold:

```text
F-NNN  [confirmed|suspected]  [severity: silent-wrong > corrupting > crashing > degrading]
  Where:   file:line (or flow name)
  Claim:   what the code says it does
  Reality: what it actually does under attack
  Repro:   exact command, expected vs actual   (confirmed only)
  Blast:   what leans on this
```

Grades for the health board — earned by attack log only, never by vibes:

- **bank-grade** — survived the documented attacks
- **sturdy** — no cracks found, not fully attacked yet
- **flaky** — confirmed inconsistent under stress
- **cracked** — confirmed broken

Grades are the derived summary; repros are the primary record. If anything must be cut to
keep the ledger light, grades go before repros.

## Repros

Confirmed findings keep their repro in `audit/repros/` (one small file per finding, named
by ID). Repros are deterministic, self-contained, run against safe state, and clean up
after themselves. They exist so the next run's regression sweep is mechanical: a repro
either breaks again or it does not — it cannot lie. When a finding is fixed and stable,
promote the repro into the real test suite or retire it with a one-line ledger note.

## The Ledger — AUDIT.md

One file at the target repo's root. Created on the bootstrap run, updated every run,
committed like any other file — its git history is the building's structural record.

```markdown
# AUDIT.md — structural ledger. Maintained by bedrock audits.

## Health board
| Subsystem | Grade | Last inspected |

## Open findings
F-NNN [confirmed|suspected] [severity] — one-line summary, repro pointer

## Closed findings
F-NNN — what it was · fixed <date> · proven by <repro/test>

## Load-bearing map
(what carries the building — verified each run)

## Feature inventory
(the flows as a user lives them)

## Run log
<date> · scope · re-checked N repros · new M · regressed R · not reached: ...
```

Weight budget is law: collapse closed findings, drop stale suspicions with a note, never
spawn a second file. A ledger nobody can read in one sitting is exactly the sediment this
skill exists to catch.

## Fix Mode

Opens only after the report is complete, and only when the user asked for it.

- **Hardening only.** No features, no redesigns smuggled in. Removal counts as hardening.
- **Scariest first.** Work the findings by severity — silent-wrong before crashes.
- **Definition of done, per fix:** the repro that proved the break now passes, the full
  regression sweep still passes, and the existing test suite still passes. The fix is
  proven the same way the break was.
- Update each finding to closed in the ledger with its proven-by line, and promote or
  retire its repro.
- Fixes get fresh eyes too: after the last fix, re-run the question bank against the
  changed code only — the fixer has authorship bias now, so the inspector checks its work.

## Quality Gate

The run is a real audit only if:

- Every grade on the health board traces to a logged attack attempt.
- Every confirmed finding has a runnable repro; every suspected finding says what test
  would settle it.
- The regression sweep ran first, and its results are in the run log.
- The report ends with explicit coverage honesty: inspected / not reached.
- AUDIT.md is updated, still one file, still readable in one sitting.
- Nothing was fixed during the walk (and in fix mode, every fix met its definition of done).

If the run cannot meet the gate — out of time, blocked from running things — say exactly
which parts are unverified rather than rounding up to confidence.

## What Not To Do

- Do not produce a generic code review. This is structural fragility, not code style.
- Do not report a hundred nits. Ten findings that bear load beat a hundred that do not.
- Do not claim bank-grade from reading alone. Grades are earned under attack.
- Do not hammer anything whose blast radius you have not checked.
- Do not let the report drift into "checked everything, looks sturdy!" — no attack log,
  no claim.
- Do not fix mid-walk, ever — even when the fix looks one line and obvious.
- Do not let AUDIT.md grow into a report archive. One file, one sitting, weight budget.
- Do not flag intentional ambition as sediment. Read the vision first.
