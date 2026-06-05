---
name: isomorph
description: Reason about a whole system by mapping it onto a mature, structurally-similar domain that already paid for its mistakes, then read that domain's laws, invariants, and blindspots back onto the system. Use when the user wants the big-picture / first-principles view of an architecture, codebase, product, or vision; asks "what is this really like", "find the analogy", "what are we blind to", "think about this systemically / from first principles", "is this like X"; or wants to pressure-test a design by inheriting a proven domain's failure modes. A thinking mode, not a file-producing workflow.
---

# Isomorph — Think About a System Through Its Mature Twin

Two systems are **isomorphic** when they share the same underlying structure beneath
different skins. `isomorph` takes a system someone understands only *intuitively* — a
harness, a codebase, a product, a vision — and finds its **isomorph in a mature domain**:
a twin that already solved this same shape of problem and paid for the mistakes in blood.
Then it reads that twin's hard-won **laws** back onto the system as required
**invariants**, and the laws that *don't* map become **blindspots**. The point is not to
*explain* the system with a cute metaphor. The point is to *generate the spec you didn't
have yet* and to surface what you can't see from inside your own frame.

This is a real, named way of thinking (see **The lineage** at the bottom). But during a
run you never say the academic names out loud. Those are bones under the skin.

## The feel — this IS the spec

The texture matters more than the checklist. A correct run feels like a back-and-forth
where two people build a world together and then live inside it. Hold this voice:

- **Iterative, not a dump.** The user throws a rough direction; you sharpen it; they
  push; you extend. Never answer with a one-shot framework lecture.
- **The latch gets refined.** Their first guess at the domain is a *direction*, not the
  answer. Sharpen it until it's precise. ("is it biohacking?" → "no — biohacking tweaks
  one organism; you're moving a mind between bodies; that's *transplant* — sharper,
  *re-sleeving*.") That sharpening is half the magic.
- **Build a world they can stand inside.** Map the parts one-to-one with concrete nouns,
  in the metaphor's *own* vocabulary, until they can *feel* it. The user's north-star
  phrasing for this is literally: *"i want to feel it."* Honor that.
- **Then turn it generative.** Once the world is real, stop describing and start mining:
  the twin's laws → the system's invariants → the blindspots. The analogy must do *work*.
- **Plain, vivid, grounded language the whole way.** No "TRIZ", no "FMEA", no
  "structure-mapping" spoken during the run. If a sentence sounds like a textbook, rewrite
  it as the world.

If a run produced a pretty metaphor and *no* invariants and *no* blindspots, it failed.
That's decoration. Redo it.

## When to proc

- "what's the best analogy for this whole thing / what is this really *like*?"
- "think about this big-picture / systemically / from first principles"
- "what are we blind to? what haven't we considered?" (beyond a bug list)
- "pressure-test this design" / "is this foundationally sound?"
- the user is trying to *map out* a system they built intuitively and wants to engineer
  it deliberately, or to inherit a proven domain's failure modes.

## When NOT to proc

Say so plainly rather than forcing a metaphor:

- **The problem is concrete and local.** "Why is this function slow" wants a fix, not a
  cosmology. Just fix it.
- **No mature twin exists.** If the system is genuinely novel in its *structure* (not
  just its surface), there's no donor domain to inherit from — go first-principles
  instead and say that.
- **The only available analogy is surface-deep.** A twin that shares looks but not
  *structure* will hand you the wrong laws. Better to name that than to mislead.

## The loop — moves, not a forced march

Run as many as the problem needs, in roughly this order. Skipping moves is fine; forcing
all eight on a small problem is the kitchen-sink failure.

1. **Frame.** What *is* this system, structurally? Name its parts, what flows between
   them, what it must keep true. (You can't map structure you can't describe.)
2. **Climb.** Get to the right altitude. Too concrete and nothing rhymes with it; too
   abstract and everything does, vacuously. Climb until a real twin appears.
3. **Latch.** Float 1–3 candidate mature domains. Invite the user's rough guess; it's a
   direction.
4. **Sharpen & validate.** Refine to the *precise* twin — and run the guard: is this a
   **structural** match (the parts constrain each other the same way) or just a
   **surface** resemblance? Keep only structural twins. This guard is non-negotiable; it
   is what stops the skill (and you) from overfitting to a domain that merely *sounds*
   right.
5. **Build the world.** Map components one-to-one, concrete nouns, the twin's own
   language, until it's felt. A small table often lands best.
6. **Go generative.** Extract the twin's *laws* — the things that must hold or the twin
   dies / forks / wakes up wrong. These are the failure modes the mature domain already
   knows.
7. **Map laws → invariants.** Translate each law into a required invariant in the *real*
   system, and score it honestly: satisfied / partial / **violated**. Violations are your
   audit, derived not from reading the code but from the nature of the problem.
8. **Read the gaps.** Laws that have no clean mapping — or capabilities the twin has that
   the system lacks — are **blindspots**. Push past the known fixes: "what does this frame
   show we never even looked at?"

**Output:** ranked invariants (esp. the violated ones), the blindspots, and any
*architectural reframe* the twin implies. Keep it in the world's language.

## Two worked instances — calibration, NOT scope

These are here to tune the *feel* and prove the *moves*. They are **not** the menu of
allowed domains. Note that they use **different targets AND different source domains** on
purpose — biology once, supply-chain logistics once. Your problem is a *third point*.
Re-run the loop from scratch; do **not** reach for biology by reflex.

### Instance A — a CLI meta-harness that live-switches AI models mid-conversation, via *biology*

- **Rough latch (user):** "is it literally biohacking?"
- **Sharpened twin:** not biohacking (that enhances one organism) — it's **consciousness
  re-sleeving / a cortical stack**: moving one continuous mind between different bodies.
- **The world:** conversation = the *stack* (the soul); each model = a *sleeve* (body +
  brain); model weights/RLHF = the sleeve's *DNA*; the transcoder = the *surgeon*; native
  resume = the new body *waking up*; the harness = the *operating theatre*.
- **Laws → invariants (a few):** *Don't kill the donor* → never destroy the source
  session (found: **violated** — we overwrite originals). *Bio-compatibility before
  insertion* → the target must accept the data's native schema (violated: matched only
  after rejection). *No power-cut mid-operation* → graceful teardown (violated: we
  SIGKILL). *Know what transfers vs. what's body-bound* → carry memory, drop tool-reflexes
  (satisfied — and the lossiness is *principled*, not a bug).
- **Blindspots the frame exposed:** the *mind* can reject the organ too (carried memories
  of muscles the new body lacks); the "stack" was defined too narrowly (chat without
  world-state); the transfer is a *forged-memory / injection* surface; switches aren't
  atomic (donor killed before recipient confirmed beating).
- **The reframe it generated:** there is no real *stack* yet — the system copies
  body-to-body and prays. The twin says: **own a single canonical thread; make the model
  sessions disposable projections of it.** That one move satisfied four laws at once.

### Instance B — an autonomous bug-fixing orchestrator (issue → PR), via *supply-chain logistics*

A pipeline where a filed GitHub issue flows through agents — triage, difficulty-grading,
fixer, reviewer — and comes out as a pull request.

- **Rough latch (user):** "it's like a supply-chain factory."
- **Sharpened twin:** a **multi-stage supply chain under lean / Theory of Constraints** —
  raw material arrives, flows through specialized stations that each add value, and exits
  as a finished good shipped to the customer.
- **The world:** the filed issue = *raw material arriving at the dock*; triage =
  *goods-inwards inspection & routing*; difficulty-grading = *material grading*; the fixer
  agent = *the assembly station*; the reviewer = *the QA gate*; the merged PR = *the
  finished good shipped*; the payload handed between agents = *work-in-progress inventory*;
  each agent = *a station / supplier*.
- **Laws → invariants:** *The bottleneck governs throughput* (Goldratt) → find and
  optimize the slowest station, not the easiest one — and is per-stage lead time even
  measured? *Quality at the source (jidoka / poka-yoke)* → a bad diagnosis must be caught
  at the diagnosis station, before the fixer burns compute on the wrong fix; defect cost
  compounds at every later stage. *Garbage in, garbage out (supplier quality)* → an
  under-specified issue gets enriched or **returned** at intake, not pushed through —
  triage needs a *reject* path, not only *forward*. *Cap work-in-progress* → bound how many
  issues are in flight and how long a fix may sit; inventory is liability. *Traceability /
  lot tracking* → every PR carries which station decided what, so you can debug the
  *orchestrator itself*.
- **Blindspots the frame exposed:** **the inventory is perishable** — unlike inert factory
  stock, the repo keeps moving while an issue is in-flight, so a fix built on a
  since-changed base is *spoiled goods*; the twin has cold-chain / shelf-life logic, the
  orchestrator has none (→ needs a freshness / rebase-or-discard check). **No
  supplier-quality gate at intake** — a malformed or malicious issue flows straight in.
  **Unbounded rework loops** — reviewer→fixer ping-pong with no WIP-age limit can churn
  forever. **The bottleneck is unmeasured**, so effort lands on the visible station, not
  the governing one. **No scrap analysis** — you don't track *where* in the line issues
  die, which is the exact signal for the weakest station.

Different target, different source domain, *same moves*. That delta between the two
instances is what you generalize from — not either instance alone. And notice the
**rhyme**: both twins independently flagged an *unguarded intake* (forged memory poured
into a model in A; unvetted supplier material in B). When two unrelated mature domains
point at the same failure, that's the outside view telling you the failure is *real*.

## Guardrails — so isomorph doesn't overfit (including to itself)

- **Structural, not surface.** Move 4's guard applies to *your own* analogy. A skill whose
  whole job is "transfer structure, not surface" must never itself cargo-cult a surface.
  If you can't say *which relations* match, you don't have a twin.
- **Choose the domain fresh, every time.** Never default to biology/medicine because the
  north-star example used it. The right twin is found, not habituated.
- **The loop is a palette.** Skip moves that don't fit. And keep the honest exit: "there's
  no good mature twin here — let's reason from first principles instead."
- **Vivid must earn its keep.** Every mapped noun has to produce a law, an invariant, or a
  blindspot. If it's only poetic, cut it. The world is a tool, not a poem.
- **Don't recite the bones.** The lineage below is for *your* depth, not the user's ear.

## Quality gate

A run is good only if it produced:

1. A *structural* twin (you can name the matching relations, not just the vibe).
2. At least a few of the twin's **laws**, each mapped to a concrete **invariant** in the
   real system and scored satisfied / partial / violated.
3. **Blindspots** that were not visible from inside the original frame.
4. Bonus: an **architectural reframe** the twin implies.

Metaphor with no invariants and no blindspots = failure. Redo.

## The lineage — hidden bones (for depth, never spoken during a run)

Every move is a named discipline. Reach into one of these when a step needs more rigor;
never narrate them to the user.

| Move | The discipline underneath | Why it works |
|------|---------------------------|--------------|
| Frame | **Systems thinking** (Meadows: stocks, flows, feedback, leverage points) | Gives a grammar for the structure you're about to map |
| Climb | **Abstraction laddering** | Controls the altitude where a real twin becomes visible |
| Latch / Sharpen | **Design-by-Analogy; Biomimicry; TRIZ** (Altshuller) | The disciplined "this is already solved in another domain — go get the principle" |
| Sharpen (the guard) | **Structure-Mapping** (Gentner, 1983) + **first-principles** | Good analogies carry *relations*, not looks; first-principles is the check against false analogy |
| Build the world | **Structure-Mapping** (the explicit one-to-one correspondence) | Forces a concrete, checkable mapping rather than a hand-wave |
| Go generative / Map | **The Outside View / Reference-class** (Kahneman; Flyvbjerg) | Inherit the mature class's failure stats instead of rediscovering them |
| Read the gaps | **FMEA / Premortem** (safety eng.; Klein) + **Inversion** (Munger) | Systematic "how does this fail / what did we not look at" |
| When NOT to proc | **Cynefin** (Snowden) | Tells you when the domain is too novel for analogy and you should go first-principles |

The deep point the lineage encodes: **define what the system actually needs to succeed
*before* assuming the obvious unit of work is the right one.** The twin almost always
shows the unit was drawn too narrow.

## What not to do

- Don't proc for a concrete, local fix the user just wants done.
- Don't lecture. No academic names during a run; build the world instead.
- Don't keep a twin you can't defend structurally.
- Don't default to the example domains; find the fresh twin.
- Don't stop at a pretty metaphor — push through to invariants and blindspots, or it failed.
- Don't force all eight moves on a small problem.
