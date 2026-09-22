---
name: probe
description: Resolve a consequential uncertainty with the smallest useful experiment before committing to a larger direction. Use when the user asks to test an assumption, check feasibility, run a bounded spike, or find out whether an approach works before building it. Define success, failure, limits, and cleanup before execution; distinguish observed results from inference. Runs authorized reversible experiments and returns evidence to the decision, without expanding into full implementation.
---

# Probe — Learn Enough to Make the Next Decision

Probe turns one important unknown into an experiment whose result can change what happens
next. The deliverable is evidence about that unknown. A prototype, script, measurement,
or observed task can be the means. Stop when the experiment answers its question or reaches
its declared limit.

## When to use

- "Test this assumption before we commit"
- "Can this actually work with what we have?"
- "Run a small feasibility spike"
- "What is the smallest experiment that would settle this?"
- `decide` identifies a consequential unknown and the user authorizes investigating it.

## When not to use

- Existing evidence or a direct lookup settles the question: use it; `scour` can verify
  external claims when needed.
- The task is to understand existing code: use targeted reading or `devour`.
- The user wants a known bug fixed or a decided feature built: do the work normally.
- The task is a structural audit or a whole-journey stress sweep: use `bedrock` or `gauntlet`.
- The answer would not affect a decision: explain why the proposed experiment adds little.

## Preflight — define the experiment before running it

Read the existing context first. Briefly state the following in the conversation or the
project's existing experiment record. Fill in real values appropriate to the question:

```text
Decision this informs: <what we will do differently depending on the result>
Assumption: <one falsifiable claim>
Experiment: <smallest setup that exercises the relevant mechanism>
Evidence: <observation or independent check; source of expected behavior>
Outcomes: <what would support, contradict, or leave the claim inconclusive>
Limits: <scope, attempts, time/resources as relevant; when to stop>
Authority and cleanup: <allowed actions, isolation, temporary state to remove>
```

Choose a reasonable local limit if none was provided and explain it; do not invent a
business deadline or monetary budget. Ask only when missing information changes the
question or required authorization. A user asking to design an experiment authorizes a
plan; asking to run a bounded local probe also authorizes its necessary reversible local
setup. Existing authorization carries forward.

## Operating boundary

- Prefer temporary local workspaces, disposable fixtures, synthetic data, and test modes.
  Inspect what commands and integrations touch before executing them.
- Use the active host's available tools. Do not require a particular provider or harness.
- Keep existing user work intact. Record owned files, processes, and state so cleanup is
  precise; never reset an entire working tree or shared database to undo a small probe.
- Reuse read-only access already available. Remote writes, purchases, deployment, sending
  messages, recruiting participants, or touching real-user data require authorization
  covering those actions. A skill transition does not create it.
- Prefer scratch artifacts. Do not modify production behavior as part of an experiment.
  Retain a harness or update a project record when requested; otherwise include enough
  commands, inputs, and observations in the answer for someone to repeat the result.
- If safe execution or necessary access is unavailable, return an **unrun experiment
  plan** and the exact missing prerequisite. Do not count designing a test as testing it.

## Workflow

### 1. Isolate the assumption

Split a vague claim such as "this dashboard will work" into the unknown governing the
next decision. Test one coherent question at a time. Separate technical feasibility,
correctness, performance, usability, and demand; evidence for one does not establish the others.

### 2. Choose a discriminating experiment

Exercise the real mechanism that could fail. Define expected results independently of
the implementation under test, using the relevant specification, raw inputs, or known
control. A simulation can isolate a mechanism; identify which boundaries it replaces.
Include a negative or boundary case when it helps distinguish success from a broken harness.

Use the smallest scope that can separate the credible explanations. A tiny happy-path
demo cannot establish reliability at scale. An agent's simulated user cannot establish
real human usability or market demand.

### 3. Run within the limits

Execute the stated experiment. Record relevant configuration, code revision or dirty
scope, input data, commands, observations, and errors without retaining secrets. Keep
direct observations separate from interpretation. Diagnose obvious harness failures before
attributing them to the system. Stop when the question is answered or a limit is reached.

If the question or method must change, explain why and update the experiment record before
the new run. Preserve the earlier result. Do not move the success criteria after seeing an
unfavorable outcome or repeatedly enlarge the experiment until it succeeds.

### 4. Interpret the evidence

Return **supported within the tested scope**, **contradicted**, or **inconclusive**.
Identify alternatives the experiment did not rule out. A failed setup or exhausted
budget may leave the underlying claim inconclusive. A failed approach is useful evidence;
it is not permission to implement a different approach.

Explain the consequence for the decision. Return to `decide` if a tradeoff remains;
otherwise state the next step. After cleanup, carry the result into further work that
was already authorized. Reaching the experiment's limit ends the experiment, not the
user's larger task.

### 5. Clean up and deliver

Stop owned processes, remove temporary state, and check the baseline you recorded before
the run. Preserve user changes. Report anything intentionally retained or not restored;
cleanup failures remain outstanding work, not a successful closeout.

Summarize evidence before leaving scratch behind. Retain useful code only through an
explicit handoff into the requested implementation or artifact; experimental shortcuts
do not silently become production dependencies.

For a chain, use [WORKFLOWS.md](../../WORKFLOWS.md). Probe is also a complete standalone
workflow; no prior `decide` run or follow-on build is required.

## Output

```text
Question / decision: <what was being tested and why>
Status: <supported within scope | contradicted | inconclusive | unrun plan>
Method and limits: <setup, independent check, attempts, environment>
Observed: <results with commands, inputs, or other repeatable evidence>
Meaning: <what follows; what remains unproven>
Next: <decision consequence and authorized action, if any>
Cleanup: <baseline restored; retained artifacts or outstanding state>
```

An unrun plan uses prospective language and states which access or authorization is missing.

## Worked instances — hypothetical calibration

These illustrate different evidence needs. Choose a fresh method for the actual question.

### Can an event be followed across an agent system?

Before designing a live observation interface, send a synthetic event through an isolated
real pipeline and check that its identifier, timestamps, and outcome reach the read side.
Include a retry to test whether repeated delivery remains recognizable. Define required
fields and acceptable delay before running. Report missing correlation as evidence
against the current mechanism; a single successful trace supports that path's feasibility,
while throughput, reliability, and operator usefulness remain unproven. Remove test state.

### Does a revised guide help someone complete an onboarding task?

Define the task, completion criterion, allowed assistance, and comparison with the existing
guide before the trial. If an authorized participant is available, observe the task and
record completion, assistance, and where they hesitate. State the sample and limits;
one participant does not prove a general improvement. Without participant access, deliver
an unrun plan or a clearly labeled editorial check. Do not manufacture observations or
substitute an agent role-play for a human trial. Contacting someone requires authorization.

## Quality gate

1. The assumption is falsifiable and its answer changes a named decision.
2. Outcomes, scope, resource limits, authority, and cleanup were defined before execution.
3. The experiment tests the relevant mechanism and names its independent evidence.
4. Execution status and direct observations are distinguishable from inference.
5. The conclusion stays within the tested conditions and returns a decision consequence.
6. Owned state is cleaned up or precisely reported as outstanding; user work is preserved.

The worst failure is a successful-looking demo that leaves the important assumption
untested. If the method cannot distinguish the outcomes, revise it before running. If the
result is overstated, narrow the conclusion. Run again only when a justified question and
the remaining authorization and limits support it; never loop to manufacture confidence.
