---
name: potential
description: See what a codebase wants to become and which opportunities deserve attention. Ground possibilities in existing structure, assess who benefits, ongoing burden, opportunity cost, and smaller alternatives. Two modes - open (what could this become) and wish (whether and how the structure can grant a wish). Use when the user asks what is latent, what features could emerge, whether a capability is being used fully, or says run potential. Conversational; never implements or writes files within this mode.
---

# Potential — See What the Building Wants to Become

Bedrock walks the building as the inspector; `potential` stands across the street as the
developer — the one who looks at a warehouse and sees the loft. Same building, opposite
posture. But the developer is still an engineer: they do not see what they *wish* were
there, they see what the structure *wants to become*. Every vision is read off real
beams.

The skill exists because builders, like auditors, see locally: heads-down sprints add
what was asked and never notice what the accumulated structure now makes nearly free.
Potential is the deliberate step back across the street.

## The Constitutional Rule

**No idea without structural evidence.** Every vision must point at the existing
structure that carries it — "you already built X and Y; Z is implied, and the building
already does most of it." If an idea could have been generated without reading this
codebase — *add dark mode, add export, add AI* — it is a PM listicle item, not a
potential, and it dies before the report. Existing structure earns an idea a closer
look; usefulness and the cost of keeping it alive still need their own evidence.

## Activation

Use this skill when the user asks for any of these:

- "what could this become?" / "what's latent in this codebase?"
- "squeeze the potential of this feature" / "are we using this fully?"
- "what features want to be born here?" / "practice imagination on this"
- "run potential" / "potential this"
- "I wish it could ..." (wish mode)

Do **not** use it for: implementing a feature the user already decided on (just build
it), market or competitor research (potential reads *this* building, not the market),
auditing fragility (that is `bedrock`), or studying a codebase before changes (that is
`devour`).

## Two Modes

**Open mode** — no seed. Walk the building, come back with a small portfolio of what the
structure wants to become. The building speaks first.

**Wish mode** — the user brings a wish: "I wish it could X." Read the structure and give
the wish a real answer. If the vision declares an adopted system twin, take the wish to
the twin first — "how does a hospital interrupt people?" — and let the proven pattern
shape the answer before grading what the structure can carry:

- **Grantable** — the beams that carry it already exist; here is what is missing and how
  little it is.
- **Not grantable as asked** — the structure does not support it; say so plainly and say
  what would have to exist first.
- **A sharper wish** — the building cannot grant X, but the same structure offers
  something adjacent and better. Reshaping the wish is a first-class outcome, not a
  failure to answer.

In both modes the output is a grounded opportunity. Potential itself never implements
or writes files. A standalone request ends with those opportunities. When the user
chooses one and authorizes building, leave this mode and carry the evidence into that
work without requiring another invocation. Use `decide` if a consequential choice
remains, or `probe` for an assumption that must be tested first; neither is mandatory.
For longer journeys, use [WORKFLOWS.md](../../WORKFLOWS.md).

## Host-Agnostic Contract

This skill must work in Codex, Claude Code, and any other coding-agent host. Use whatever
file, search, and git tools the host exposes; never depend on a host-specific tool by
name. Cite structure in plain file/flow terms any host could follow.

## Posture

- **Across the street, not at the whiteboard.** Visions come from reading the structure,
  not from brainstorming over it.
- **Few and deep beats many and shallow.** An open portfolio usually has three to five
  visions, fewer when the evidence supports fewer. Wish mode addresses the wish without
  padding it into a portfolio. Each opportunity carries its evidence.
- **The vision is the client.** Read what the building is *trying to be* (README,
  CLAUDE.md / AGENTS.md, stated intent) before dreaming. A potential either serves that
  vision or is honestly flagged as *extending* it — never silently redirecting it.
- **Honest distance.** Never inflate how close a vision is. The grades exist so the user
  can feel the real distance from here to there.

## The Moves

Five ways a building reveals what it wants to become. Run them across the structure;
they are the dreamer's question bank:

- **Squeeze** — a feature running at a fraction of what its machinery supports. The
  engine is built; the throttle is barely open. What does full extraction look like?
- **Birth** — your pattern exists in two places; the third instance is implied and the
  structure already does most of it. Features wanting to be born.
- **Combine** — two existing structures whose product is bigger than their sum, and
  nobody has connected them.
- **Expose** — capability that already exists internally but has no door. The cheapest
  vision of all: the room is built, just unlock it.
- **Generalize** — a special case begging to be the general case it secretly is. The
  hardcoded path that is one parameter away from a capability.

## The Grounding Walk

Before any vision is voiced:

1. **Read the vision docs** — `VISION.md` at the repo root if it exists (the vision
   skill's artifact), otherwise README / CLAUDE.md / stated intent. What the building is
   trying to be is the frame everything hangs inside.
2. **Use the maps that exist.** If `MAP.md` is at the repo root (devour's persisted
   atlas), read it: it is the structure to dream from. If `AUDIT.md` is there too
   (bedrock's ledger), read that as well: the load-bearing map says what the structure
   can carry, the feature inventory says what exists to squeeze. Same building, other
   side of the street. Treat both as claims to spot-check, not truth.
3. **No maps? Walk it yourself.** A fast structural read — entrypoints, feature surfaces,
   shared machinery, what writes state — enough to cite real beams. Depth of evidence
   over breadth of coverage.

Every vision cites its beams as file or flow references a stranger could check.

## Structural Cost Grades

Every vision carries an honest distance grade:

- **already-built** — the machinery exists; the missing work is exposing it safely.
- **one-beam** — one real addition and the existing structure carries the rest.
- **new-wing** — a genuine project, but the foundation demonstrably supports it. Said
  plainly, never disguised as one-beam.

Plus vision-fit: **serves** the stated vision, or **extends** it (flagged, so the user
decides whether the building's ambition grows).

These grades describe structural distance. They are not calendar estimates, evidence of
demand, or permission to ignore rollout, integration, support, and operating costs.

## Does the opportunity deserve to exist?

For each serious opportunity, answer briefly:

- **Beneficiary and situation:** who would use it, at what moment, and what improves?
  Cite existing user evidence when available; otherwise label the benefit as a hypothesis.
- **Ongoing burden:** who would maintain or operate it, what new failure paths appear,
  and which support, data, compatibility, or service costs continue after the build?
  Mark ownership and costs unknown when they have not been established.
- **Opportunity cost:** what known priority would be delayed or complicated? If priorities
  are unknown, say so rather than inventing a roadmap.
- **Smaller alternative:** could exposing an existing control, improving a default, or
  narrowing the audience deliver most of the benefit? Keeping the current behavior can
  also be reasonable.

Give a provisional judgment: **worth exploring**, **conditional on evidence**, or
**leave dormant**, with the reason. Keep an interesting but unproven opportunity visible
without presenting it as a recommendation to build. Deep comparison and commitment belong
to `decide`; potential supplies the candidates and the evidence that makes them credible.

## The Back-and-Forth — this is the texture

Like `isomorph`, a correct run feels like two people standing across the street from the
same building, pointing. Never a one-shot dump.

- **Open mode:** present a few earned opportunities: *benefit and evidence, supporting
  structure, distance and fit, ongoing burden, opportunity cost, smaller alternative,
  provisional judgment*. Keep each concise; a small table can carry the comparison.
  For exploration alone, stop and let the user point. For an already-authorized workflow,
  pass the findings to the next stage with the user's priorities intact.
- **Deepen on demand:** when the user points at one, go deep — which structures carry
  it, what is genuinely missing, what it would unlock *next* (potentials compound), and
  the first beam to place if they ever build it.
- **Wish mode is a dialogue too:** take the wish seriously, answer it honestly, and when
  the structure suggests a sharper wish, offer it back. The user's wish is a direction,
  not a spec — same as isomorph's first latch.
- **Stay in the building's language.** Concrete nouns from this codebase, not generic
  product-speak.

## Quality Gate

A run is good only if:

1. Every vision cites real structure (file/flow references) — the constitutional rule
   held.
2. Open mode returns a small, grounded portfolio; wish mode directly addresses the wish.
3. Every grade is honest — no new-wing dressed as one-beam.
4. In wish mode, the wish got a real answer: grantable / not grantable / sharper wish.
5. Nothing was implemented and no files were written.
6. Vision-fit was checked against what the building is trying to be.
7. Each serious opportunity names a beneficiary, ongoing burden, opportunity cost, and
   smaller alternative, with missing evidence explicitly marked.
8. Feasibility and value have separate judgments; no time estimate or user demand was
   inferred merely because supporting code exists.

A pretty idea with no beams under it is decoration. Cut it or find its evidence. If
technical proximity is the only argument for pursuing it, redo the value assessment.

## What Not To Do

- Do not produce PM listicles or market-shaped features ungrounded in this building.
- Do not present twenty shallow wishes; present a few that are earned.
- Do not inflate proximity — distance honesty is what makes the portfolio trustworthy.
- Do not build inside potential. Finish its opportunity assessment, then transition
  only when implementation is already authorized.
- Do not write files. The output lives in the conversation; keeping it is the user's call.
- Do not override the building's stated vision with your own taste — extensions are
  flagged, never smuggled.
- Do not skip the grounding walk because an idea feels obvious. Obvious and unevidenced
  is exactly the slop this skill exists to refuse.
