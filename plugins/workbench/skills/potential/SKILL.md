---
name: potential
description: See what a codebase wants to become. The generative counterpart to a foundation audit - read the existing structure and surface the features it already implies, the capacity it isn't using, and the doors it hasn't opened. Two modes - open ("what does this want to become?") and wish (the user brings "I wish it could X" and the structure answers whether and how it can grant it). Use when the user asks what could this become, squeeze the potential of this feature, what features want to be born, what's latent here, run potential, or starts a sentence with "I wish it could". A conversational thinking mode like isomorph - it never implements and never writes files.
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
potential, and it dies before the report. The visionary's ideas are cheap because the
building already paid for them.

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

In both modes the output stays a wish. Potential never implements, never opens a fix
phase, and never writes files — it is a thinking mode, like `isomorph`. If the user wants
a vision kept somewhere, that is their call to make afterwards, not the skill's.

## Host-Agnostic Contract

This skill must work in Codex, Claude Code, and any other coding-agent host. Use whatever
file, search, and git tools the host exposes; never depend on a host-specific tool by
name. Cite structure in plain file/flow terms any host could follow.

## Posture

- **Across the street, not at the whiteboard.** Visions come from reading the structure,
  not from brainstorming over it.
- **Few and deep beats many and shallow.** A portfolio is three to five visions, each
  carrying its evidence. Twenty shallow wishes is the listicle failure wearing a coat.
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

- **already-built** — the machinery exists; only the door is missing. Days, not weeks.
- **one-beam** — one real addition and the existing structure carries the rest.
- **new-wing** — a genuine project, but the foundation demonstrably supports it. Said
  plainly, never disguised as one-beam.

Plus vision-fit: **serves** the stated vision, or **extends** it (flagged, so the user
decides whether the building's ambition grows).

## The Back-and-Forth — this is the texture

Like `isomorph`, a correct run feels like two people standing across the street from the
same building, pointing. Never a one-shot dump.

- **Open mode:** present the portfolio — each vision in a few lines: *the vision, the
  beams that carry it (cited), the cost grade, the fit*. Then stop and let the user
  point.
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
2. The portfolio is small and deep — three to five, each one earned.
3. Every grade is honest — no new-wing dressed as one-beam.
4. In wish mode, the wish got a real answer: grantable / not grantable / sharper wish.
5. Nothing was implemented and no files were written.
6. Vision-fit was checked against what the building is trying to be.

A pretty idea with no beams under it is decoration. Cut it or find its evidence.

## What Not To Do

- Do not produce PM listicles or market-shaped features ungrounded in this building.
- Do not present twenty shallow wishes; present a few that are earned.
- Do not inflate proximity — distance honesty is what makes the portfolio trustworthy.
- Do not drift into building it. The skill ends at the vision, every time.
- Do not write files. The output lives in the conversation; keeping it is the user's call.
- Do not override the building's stated vision with your own taste — extensions are
  flagged, never smuggled.
- Do not skip the grounding walk because an idea feels obvious. Obvious and unevidenced
  is exactly the slop this skill exists to refuse.
