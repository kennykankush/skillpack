# Workbench workflows

Skills are independently useful ways of working. These recipes connect them around an
outcome when the user wants a longer journey. A recipe is guidance for the current agent;
it does not launch agents, require a separate orchestrator, or authorize extra actions.

## The shared shape

```text
Establish intent → understand reality → choose a direction → build → verify → preserve
                          ↑                    |
                          └── resolve a consequential unknown ──┘
```

| Stage | Use when needed | Done when |
|---|---|---|
| Intent | Existing conversation or project vision; `vision` to maintain it when requested | The outcome and important constraints are clear |
| Understanding | `devour`, `scour`, `research-report`, `totality` | Evidence is sufficient for this decision or change; remaining unknowns are named |
| Direction | `potential` for opportunities, `isomorph` for structural alternatives, `decide` for choosing | A recommendation or authorized choice has reasons and accepted tradeoffs |
| Experiment | `probe`, between understanding and commitment as needed | A consequential assumption is tested or explicitly remains unresolved |
| Execution | Normal implementation; `max-prompt` for a separate recipient | The requested behavior exists within the agreed scope |
| Verification | Relevant tests; `bedrock` for structural audits, `gauntlet` for journey sweeps | Claims match recorded evidence and coverage |
| Continuity | Maintain affected project artifacts; `memory-scriber` or `skill-distiller` when requested | The next session can recover decisions, evidence, and remaining work |

Only load a skill when its method is needed. Small concrete tasks can pass through the
whole shape with ordinary investigation, implementation, and verification.

## Rules for composing skills

1. **Enter at the unresolved stage.** Read existing context first. A clear vision, a
   current map, or an already-chosen direction can satisfy a stage without rerunning its skill.
2. **Choose by the missing answer.** External facts call for research; unknown technical
   feasibility may call for a probe; an existing defect calls for debugging. Avoid using a
   broad audit to answer a local question.
3. **Set the scope and exit before going deep.** Name the question, area, required evidence,
   and relevant limits. Widen only when dependencies or new findings make it necessary;
   explain the connection. Mark uncovered areas instead of silently claiming full coverage.
4. **Carry evidence forward.** Check freshness where material. Do not restart a completed
   investigation or replace the objective with a sibling skill's preferred framing.
5. **Carry authorization forward too.** "Choose an approach and implement it" already
   authorizes that transition within scope. "Explore this" ends with exploration.
   Publishing, messaging, spending, or other actions need authority covering those actions.
6. **Respect steering immediately.** "Build that" exits discussion into authorized work;
   "let's think first" pauses implementation. Update the next step without losing the evidence.
7. **Stay modular.** A standalone skill stops at its own output. Name a helpful next step
   only when useful; do not auto-enroll the user into a recipe or demand a new invocation
   when the next stage of an authorized workflow is already clear.
8. **Bound rework.** Revisit a decision when new evidence could change it. A failed probe
   returns its result; it does not justify indefinite experiments or quietly expanded scope.

## The handoff

Maintain this compact context in the conversation or the existing project document. It
is not a mandatory new file, repeated status template, or requirement to fill empty fields.

```text
Outcome and constraints: what we are pursuing; whose priorities govern it
Established: evidence, source/revision/date where relevant, and what it supports
Decision: recommendation or actual choice; owner, reasons, and accepted downside
Unknowns: what remains uncertain; which could change the direction
Next: action, completion evidence, scope, and current authorization
```

The receiving skill reuses this context and checks only what its task needs. A choice
becomes accepted only through the user's words or authority already delegated to the agent.
If the work moves to another agent, `max-prompt` can package this into an executable brief.

## Recipe 1 — Find and build the next opportunity

```text
devour → potential → decide → implementation → verification
                       ↕
                     probe
```

- **Enter:** an existing product needs a useful next direction. Read its intent and map;
  choose `devour refresh` for an existing map whose relevant parts have changed.
- **Discover:** `potential` returns supported opportunities with benefit, ongoing burden,
  opportunity cost, and a smaller alternative. Hand those forward rather than rereading the repo.
- **Choose:** `decide` compares the credible options. Use `probe` only for an answerable
  uncertainty that could change the recommendation. Return its evidence to the choice.
- **Execute:** build when authorized. If only exploration was requested, stop at the
  recommendation. Use `max-prompt` if the user wants a handoff instead of execution here.
- **Verify:** run relevant checks. Use `gauntlet` when proving the complete journey is in
  scope; use `bedrock` when a structural audit is needed. Neither is a mandatory release step.
- **Leave behind:** the implemented change, its evidence, and updates to affected existing
  artifacts within scope. A chosen opportunity does not require rewriting the whole vision.

## Recipe 2 — Give a new idea a workable shape

```text
exploration → isomorph / scour as needed → decide → vision → first implementation
                                           ↕
                                         probe
```

- **Enter:** an idea lacks a settled shape. Start from the user's spark and desired
  experience. There may be no repo to devour and no existing structure for `potential`.
- **Investigate:** use an analogy when structure needs explanation, web evidence when
  external facts matter, and `totality` only when the complete surface is requested.
  Analogy-derived requirements remain candidates until justified for the actual system.
- **Choose:** compare feasible shapes and identify the first serious workflow. An experiment
  can answer a crucial feasibility question before a large build is proposed.
- **Record:** use `vision` when recording project intent is requested. Maintain an existing
  vision home; skip writing when the user only wants to discuss the idea.
- **Execute:** build and verify the first meaningful slice when authorized. Capture what
  it established and what it leaves open, so the next decision can use real evidence.

## Recipe 3 — Harden an existing product

```text
targeted orientation / devour refresh → bedrock → authorized fixes → verification
```

- **Enter:** the user requests a structural audit. A concrete bug goes straight to normal
  debugging; it does not need the full recipe.
- **Orient:** reuse the vision, map, and audit ledger. Refresh relevant stale understanding;
  skip a fresh devour when the audit already has adequate context.
- **Inspect:** bedrock owns its attack log, findings, and report-before-fix discipline.
  Report-only requests end there. A request to audit and fix continues into the fixes.
- **Verify:** rerun the reproductions and relevant regression checks. Add a `gauntlet` only
  when the requested journey or newly discovered interactions warrant it.
- **Leave behind:** closed or open findings with evidence, retained reproducible cases,
  and an honest statement of coverage. Do not manufacture a second ledger for the same defects.

## Ownership of durable context

| Context | Home and responsibility |
|---|---|
| Project intent | Existing vision home, commonly `VISION.md`; `vision` maintains it from user intent |
| Code understanding | `MAP.md`; `devour` records revision, dirty scope, and verification coverage |
| Defects and reproductions | Existing finding ledger, commonly `AUDIT.md`; `bedrock` maintains it and `gauntlet` contributes compatible findings |
| Decision or experiment | Conversation by default; an existing project record when persistence is requested |
| Journey observations | Gauntlet's run diary, with observations separated from inferred experience |
| Session learning | Active host's permitted memory mechanism, only when requested or pre-authorized |

Shared documents carry useful state rather than duplicated transcripts. Refresh only
what was checked; unchanged paragraphs do not acquire new verification dates automatically.
