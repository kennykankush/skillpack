---
name: decide
description: Turn competing options and available evidence into a reasoned recommendation, with the tradeoffs, unresolved assumptions, and conditions for revisiting it. Use when the user asks which direction to take, what to prioritize, whether something is worth doing, to weigh alternatives, or to decide between opportunities. Works for product, architecture, operations, and other consequential choices. Conversational by default; a recommendation alone does not authorize implementation.
---

# Decide — Choose a Direction You Can Explain

Decide helps the user reach a commitment they can understand and revisit. It carries
the useful parts of exploration into a choice: what matters, which options are credible,
what each costs, and why one fits this situation. A well-supported decision can also be
to do less, postpone, or run one experiment before committing.

## The feel

Be a thoughtful colleague at the decision table. Lead with the recommendation when the
evidence supports one, explain the tradeoff that governs it, and make disagreement easy.
The user's priorities determine the criteria. Preserve unusual preferences that change
the choice; do not replace them with generic industry priorities.

Keep small decisions small. A few connected sentences can carry the whole method.
Use a comparison table when several options need to be assessed on the same criteria.

## When to use

- "Which direction should we take?" / "help me decide"
- "Which of these opportunities deserves our time?"
- "Is this worth building?" / "what should we prioritize?"
- "Compare these approaches and recommend one"
- A requested workflow has reached a consequential choice after discovery.

## When not to use

- The user already chose and wants execution: carry that decision into the work.
- A straightforward question has an established answer: answer it directly.
- The desired outcome itself is still forming: continue exploration; use `vision` when
  the user wants the resulting project direction recorded.
- Possibilities are missing: `potential` can find opportunities in existing code;
  `scour` or `research-report` can establish external alternatives.

These are available moves, not prerequisites. Decide works without a repo or prior skills.

## The loop

### 1. Name the decision

Identify the outcome, who owns the choice, its scope, and any real deadline. Separate
hard constraints from preferences. Read relevant conversation, project intent, and prior
decisions before asking questions. Ask only when an unresolved priority would materially
change the recommendation; otherwise state the working assumption and proceed.

### 2. Establish the evidence

Use supplied options and findings. Inspect available source material where it governs
the choice. Separate observations, supported inferences, assumptions, and unknowns.
Verify external facts that can change; use the host's research tools or `scour` as needed.
Use `devour` only when missing code understanding warrants that depth.

Evidence has a scope and a date or revision where relevant. A previous recommendation
is a claim to reconsider. A new conversation does not require repeating valid research.

### 3. Compare credible options

Usually compare two to four serious options. Include a smaller intervention, the current
approach, or postponement when viable. Do not invent weak alternatives to make one win.

Choose only the criteria that could change this decision, such as:

- Benefit to the intended user or operator, supported by evidence or labeled as a hypothesis.
- Implementation effort, ongoing ownership, maintenance, and operational cost.
- Compatibility with the project's direction and existing constraints.
- Failure consequences, reversibility, dependencies, and opportunity cost.

Distinguish hard exclusions from negotiable disadvantages. Use qualitative comparisons
unless real data supports numbers. If weighted scoring is useful, explain the weights
and check whether plausible changes would reverse the result. Precision must be earned.

### 4. Challenge the leading option

State its strongest objection and the assumption most likely to overturn it. Explain
what evidence would favor the next-best option. Evaluate it against the actual objective;
ease of building and personal enthusiasm are relevant inputs, not sufficient proof of value.

If one answerable unknown controls the choice, specify the question for `probe` or a
direct lookup. Recommend the smallest useful check. Do not turn every uncertainty into
an experiment or keep investigating facts that cannot change the decision.

### 5. Recommend and hand off

Give a direction, reasons, the accepted downside, and a concrete revisit condition.
Use an observable trigger where possible: a requirement changes, a measured limit is
crossed, or the key assumption fails. If evidence cannot yet support a choice, identify
the blocking unknown and the next check instead of manufacturing certainty.

Keep the status explicit: **recommended**, **chosen by the user**, or **chosen under
delegated authority**. Only claim the latter two when the conversation supports them.

The default output is in chat. If asked to record the decision, maintain its existing
home; `vision` owns changes to project intent. A recommendation does not itself grant
permission to implement, purchase, publish, or change external state. When the user has
already authorized the next action, transition into it without asking again. Use
`max-prompt` only when a separate recipient needs an executable brief.

For a chain, use the shared handoff in [WORKFLOWS.md](../../WORKFLOWS.md). A standalone
decision ends with the recommendation and next action; it does not launch a chain.

## Output

Adapt this to the size of the choice; omit empty sections:

```text
Decision: <the choice and intended outcome>
Recommendation / status: <direction; recommended or actually chosen>
Why: <decisive evidence and criteria>
Alternatives: <credible options and the tradeoffs that matter>
Accepted downside: <what this choice gives up>
Uncertainty: <what could reverse it; evidence still needed>
Revisit when: <observable condition>
Next: <action, owner if known, and current authorization>
```

## Worked instances — hypothetical calibration

These differ in domain and governing criteria. Derive the comparison fresh for each task.

### An application needs background work

The candidates are an existing database-backed worker, a managed queue, and delaying
async processing for a narrow first release. Check actual delivery requirements, load,
failure handling, and who will operate it. If the existing worker meets the requirements,
its lower operational burden can justify it; record the throughput or isolation condition
that would favor the managed queue. If retry behavior is unknown and changes the choice,
hand that assumption to `probe`. Do not recommend a queue from fashion or a fabricated benchmark.

### A team is choosing how to onboard clients

Compare a self-service guide, a short live session, and a hybrid against client complexity,
available staff time, and observed sources of confusion. A hybrid might fit if only one
step needs assistance, but that is conditional on evidence about that step. State the
ongoing staffing burden and what completion or support evidence would justify changing
the approach. Existing interviews can inform the choice; recommending a trial does not
authorize contacting clients or inventing their feedback.

## Quality gate

A run succeeds only if:

1. The decision and criteria trace to the user's objective and constraints.
2. Alternatives are credible; facts, estimates, and unknowns remain distinguishable.
3. The recommendation explains the accepted downside and its strongest objection.
4. A consequential uncertainty is resolved, explicitly accepted, or paired with a bounded check.
5. The output includes a revisit condition and accurately states who has chosen what.
6. No action exceeded the user's authority, and already-authorized next work was not stalled.

The worst failure is a persuasive comparison constructed to bless a favorite. If the
runner-up is a straw man, scoring hides assumptions, or a recommendation is presented as
the user's decision, rebuild that part from the evidence before delivering it.

## What not to do

- Do not reopen a settled choice without new evidence or a request to reconsider it.
- Do not invent priorities, demand, performance, costs, or deadlines.
- Do not turn a reversible small choice into a strategy workshop.
- Do not equate structural feasibility with usefulness.
- Do not write a decision document by default or invoke every companion skill.
