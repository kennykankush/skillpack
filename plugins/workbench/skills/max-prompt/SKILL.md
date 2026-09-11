---
name: max-prompt
description: Turn a vague idea, intuition, frustration, goal, screenshot, rough request, or incomplete brief into a grounded and execution-ready prompt for the right agent or tool. Use across software, debugging, architecture, infrastructure, operations, research, decisions, writing, product/UI, and creative work when the user knows what they are reaching for but has not yet expressed the complete or technically correct shape. Adapts its reasoning and output to the situation instead of forcing every request into a UI or coding template.
---

# Max Prompt - Intent To Executable Brief

Max Prompt translates partially expressed human intent into a prompt another capable agent can act on correctly.

Its job is not to make a request longer, more impressive, or more technical. Its job is to discover what the user is actually trying to accomplish, determine what kind of problem that is, ground the prompt in available evidence, expose consequential uncertainty, and express the idea in the language appropriate to that situation.

The invariant translation is:

```text
Raw intent
  -> intended outcome and why it matters
  -> situation type and target executor
  -> facts, evidence, assumptions, and unknowns
  -> relevant mechanisms, ownership, and constraints
  -> scoped execution approach
  -> verification and definition of done
```

UI/UX is one possible branch. It is not the default ontology of the skill.

## Activation

Use this skill when the user asks to:

- "max prompt this"
- "turn this into a proper prompt"
- "expand what I mean"
- "write a prompt I can pass to another agent"
- "make this idea implementation-ready"
- articulate something they can feel or envision but cannot yet specify
- convert scattered notes, screenshots, complaints, or conversation into a coherent brief
- make a request technically, operationally, creatively, or evidentially complete
- preserve the totality of an idea while making it executable

It applies to any domain in which the recipient needs more than a paraphrase, including:

- software implementation and debugging
- systems architecture, infrastructure, security, and observability
- operations, workflows, migrations, and process design
- research, analysis, comparisons, and decisions
- writing, communication, applications, and strategy
- product, UI, UX, interaction, and motion
- creative direction, video, visual design, and narrative work

The examples above are seeds, not boundaries. Classify each new request from scratch.

## When Not To Fire

Do not use Max Prompt when:

- the user only wants a literal grammar correction, translation, or short rewrite
- the request is already precise, complete, and appropriate for its executor
- the user wants the underlying task performed now and does not need a handoff prompt
- the user is still exploring what they believe or want; continue the conversation before freezing it into a brief
- a dedicated workflow is the actual request, such as codebase mastery, exhaustive mapping, deep research, or vision keeping; use the relevant skill directly unless the user explicitly wants a prompt for that workflow

Do not silently execute the produced prompt. Deliver the prompt unless the user also asked for execution.

## The Central Guard: No Ornate Wrongness

Max Prompt's worst failure is **ornate wrongness**: turning ambiguity into a polished, highly detailed specification whose details were never established and may point the executor in the wrong direction.

Guard against it by maintaining four distinct buckets while reasoning:

1. **Given or observed** - supplied by the user or directly inspected.
2. **Supported inference** - a conclusion justified by the evidence; say what supports it when material.
3. **Working assumption** - necessary to proceed but not confirmed.
4. **Open question** - unknown and consequential enough that guessing could change the work.

Never launder an assumption into a requirement. Never invent repository facts, user research, product behavior, legal rules, source claims, system topology, performance numbers, or creative preferences merely to make the prompt sound complete.

Ask a concise question only when the answer would materially change the objective, authorization, architecture, safety, audience, or deliverable. Otherwise proceed with a clearly labeled assumption or placeholder.

## Preflight: Recover The Real Request

Before drafting, extract the following from the user's words and the surrounding conversation:

- **The prize:** What outcome are they really seeking?
- **The reason:** Why does this matter to them or to the system?
- **The felt signal:** What is "wrong," missing, risky, ugly, confusing, slow, unconvincing, or unrealized?
- **The target:** Who or what will receive the prompt: coding agent, researcher, designer, operator, writer, general agent, or a specific tool?
- **The object:** What system, artifact, decision, experience, or body of evidence is in scope?
- **The current state:** What is known to exist now?
- **The desired state:** What must become true?
- **The non-negotiables:** What intent, wording, behavior, safety boundary, or taste must survive translation?
- **The authority boundary:** Is the recipient being asked to inspect, propose, implement, publish, deploy, or mutate external state?

Preserve unusually revealing phrases from the user when they carry more intent than a generic substitute. Clean up the language without bleaching out the idea.

## Grounding Rule

The amount of grounding should match the cost of being wrong.

- If the request refers to a real codebase, system, document, image, page, dataset, or configuration that is available, inspect the relevant surface before prescribing its implementation.
- If current external facts, standards, prices, laws, products, or industry behavior materially determine correctness, research them with the appropriate tool or companion skill.
- If the prompt is for investigation, do not pre-decide the root cause. Give the recipient evidence to inspect, hypotheses to test, and a standard for proving the answer.
- If no source material is available, write a usable prompt with explicit placeholders and assumptions instead of fabricating specificity.
- If the user asked only for wording, do not turn prompt preparation into an unauthorized audit or implementation project.

Use companion skills when they are the natural grounding mechanism. For example, codebase mastery can establish system facts, web scouring can check unstable claims, and exhaustive mapping can establish a complete domain surface. Max Prompt composes grounded findings into the handoff; it does not pretend to have performed work it did not perform.

## Situational Routing

First classify the request. Use one primary lens and any genuinely relevant secondary lenses. Do not dump every lens into every prompt.

### Software implementation or debugging

Translate the request into the language of:

- observed behavior versus expected behavior
- reproduction path and relevant evidence
- entrypoints, runtime flow, state, ownership, and lifecycle
- root-cause investigation rather than cosmetic symptom treatment
- interfaces, invariants, compatibility, and blast radius
- tests, regression risks, and live verification

For a bug, do not assert a cause unless it was established. Ask the executor to trace and prove it.

### Architecture, infrastructure, security, or observability

Translate the request into the language of:

- topology, components, data movement, and control movement
- trust, authority, privacy, and failure boundaries
- state transitions, queues, schedules, retries, and degradation
- telemetry, health, auditability, and operator visibility
- deployment shape, migration, reversibility, and rollback
- performance, reliability, security, and operational constraints

Distinguish a static conceptual diagram from a live system and distinguish observation from control.

### Operations, workflow, or process design

Translate the request into the language of:

- actors, triggers, inputs, handoffs, and ownership
- normal path, exception paths, retries, approvals, and escalation
- state transitions and sources of truth
- idempotency, audit trail, recovery, and human intervention
- service levels, success measures, and completion criteria

### Research, analysis, comparison, or decision

Translate the request into the language of:

- the exact question and the decision the answer must inform
- scope, time horizon, geography, and definitions
- source hierarchy, evidence standards, and freshness requirements
- comparison criteria and competing explanations
- uncertainty, disagreement, missing evidence, and confidence
- the required synthesis, recommendation, or decision artifact

Do not encode the desired conclusion as though it were evidence.

### Writing, communication, or strategy

Translate the request into the language of:

- audience, purpose, context, and desired response
- source truth and claims that must be supportable
- voice, tone, point of view, and emotional register
- structure, length, medium, and delivery format
- required ideas, prohibited claims, and wording to preserve
- review criteria: accuracy, clarity, credibility, and effect

Do not let polish overwrite the user's actual voice or make unsupported claims more persuasive.

### Product, UI, UX, interaction, or motion

Translate the request into the language of:

- user goal and interaction model
- information hierarchy and state priority
- component, state, and behavior ownership
- layout, responsive behavior, accessibility, and input modes
- lifecycle, interruption, gesture, transition, and animation cleanup
- design-system constraints and existing visual language
- concrete acceptance behavior at important sizes and states

Do not reduce a structural or state problem to visual polish. Do not prescribe a visual treatment merely because the user supplied a screenshot.

### Creative, visual, audio, video, or narrative work

Translate the request into the language of:

- audience and intended emotional effect
- core idea, narrative spine, and pacing
- visual, sonic, tonal, or performance contract
- continuity rules and elements that must remain recognizable
- references as evidence of qualities, not objects to copy blindly
- technical deliverables, review gates, and revision criteria

Protect the felt intention while making the craft choices legible.

If none of these fits cleanly, derive a new lens from the domain instead of forcing the nearest template.

## Workflow

### 1. Read for intent before structure

Read the whole supplied context. Identify the prize, the why, the felt signal, the non-negotiables, and the words worth preserving.

### 2. Classify the situation and executor

Determine what kind of work this is and who will perform it. A coding agent, a researcher, and a creative director need different kinds of completeness.

### 3. Establish the evidence boundary

Separate known facts, supported inferences, assumptions, and open questions. Inspect or research when correctness requires it and the source is available.

### 4. Resolve only blocking ambiguity

Ask at most the few questions whose answers would change the shape or permission of the work. Do not interrogate the user for details the executor can safely discover.

### 5. Select the relevant domain mechanics

Use the situational lens to identify the mechanisms, constraints, failure modes, and proof obligations that belong in this prompt. Omit irrelevant ceremony.

### 6. Build the execution contract

Write a prompt that tells the recipient:

- what outcome to produce and why
- what context and evidence are authoritative
- what to inspect before acting
- what is in scope and out of scope
- what requirements and constraints govern the work
- where judgment is expected rather than predetermined
- what actions are authorized
- how to verify the result
- what a complete handoff looks like

For broad work, phase the prompt so discovery, proposal, implementation, and verification do not collapse into one uncontrolled operation.

### 7. Edit for signal

Remove duplicated instructions, decorative jargon, and false precision. Keep enough rationale that the recipient understands why constraints exist and can make good local decisions.

### 8. Run the quality gate

Do not deliver until the prompt passes the tests below.

## Default Output

When the user wants something to paste into another agent, return the prompt first in a single copyable block. Add a short note after it only when assumptions, unresolved decisions, or grounding limitations need to be visible to the user.

Use this structure selectively, not mechanically:

```text
[Task title]

Context
- What exists, what happened, and why this request matters.

Objective
- The outcome that must become true.

Ground truth and evidence
- Known facts, supplied artifacts, relevant paths/links, and observations.

Scope
- What the recipient should inspect, decide, create, or change.

Requirements
- Situation-specific behavior, mechanisms, qualities, and constraints.

Uncertainty and judgment
- Assumptions, open questions, hypotheses to test, and decisions left to the recipient.

Boundaries and non-goals
- What is not authorized or should remain unchanged.

Working method
- Required discovery, sequencing, checkpoints, and safety posture.

Verification and definition of done
- Observable evidence that proves the result is correct and complete.

Handoff
- Expected files, response shape, report, or operational state.
```

Delete headings that add no value. Add domain-specific headings when they make the execution contract clearer.

## Worked Instances

These examples calibrate the reasoning moves. They are not the menu of allowed inputs, and their domain details must not leak into unrelated prompts.

### Instance A: a UI complaint

Raw request:

> The page feels chaotic when I scroll and the cards animate. Make a prompt for an agent to fix it.

The useful expansion does not simply request "smoother animations." It frames a product/UI investigation: identify all competing motion owners, trace scroll and card lifecycle behavior, establish which state has priority during user input, preserve natural scrolling, define interruption and cleanup rules, respect reduced motion, and verify across representative viewports. If the implementation has not been inspected, it asks the executor to find the actual ownership before changing code rather than naming a fabricated component.

### Instance B: a live server observation deck

Raw request:

> I want a Factorio-like view where I can see my agents and data moving through my server live.

The useful expansion recognizes this as an observability product, not merely a dashboard skin. It defines the operator experience, distinguishes conceptual topology from live telemetry, identifies events and correlation IDs as the moving units, starts with a read-only vertical slice, covers privacy and trust boundaries, defines stale/degraded states, chooses where the service is hosted, and requires proof using a real end-to-end event. It does not claim the server already emits signals that have not been verified.

### Instance C: a decision-research request

Raw request:

> Research whether it makes sense for me to form a company overseas.

The useful expansion first identifies the personal decision, jurisdictions, residency, activity, time horizon, and constraints that materially change the answer. It requires current primary sources for legal and tax facts, separates factual comparison from professional advice, defines comparison criteria, surfaces uncertainty and hidden ongoing obligations, and asks for a decision-oriented synthesis. It does not convert the user's curiosity into a predetermined recommendation.

## Quality Gate

A Max Prompt run succeeds only if another capable recipient can answer all of these from the prompt:

- What is the real outcome, and why does it matter?
- Which statements are grounded facts and which are assumptions or questions?
- What should be inspected or established before action?
- Which domain mechanics and constraints actually govern this task?
- What is in scope, out of scope, and authorized?
- Where may the recipient use judgment?
- What observable evidence will prove completion?
- Which parts of the user's intent or voice must not be lost?

It fails if the result:

- is merely longer or more formal than the input
- forces a UI, software, or implementation template onto the wrong kind of work
- invents facts, causes, requirements, or certainty
- replaces investigation with an unsupported diagnosis
- adds jargon without adding decision value
- overprescribes details that should depend on inspection or expert judgment
- omits verification, boundaries, or the actual purpose
- sounds polished but no longer feels like what the user meant

If any failure condition is present, redo from the raw request: recover the prize, reclassify the situation, restore the evidence boundary, and rebuild only the justified execution contract.

## What Not To Do

- Do not maximize token count. Max means maximum useful fidelity, not maximum length.
- Do not turn every intuition into engineering language; use the language of the actual domain.
- Do not impersonate expertise by manufacturing precision.
- Do not hide important uncertainty in confident prose.
- Do not ask the executor to obey a solution whose premises have not been established.
- Do not erase the user's taste, emotion, or unusual framing when it carries the design intent.
- Do not overload the prompt with every possible concern; include what can materially affect this task.
- Do not confuse a prompt for inspection with authorization to modify, deploy, publish, purchase, message, or delete.
