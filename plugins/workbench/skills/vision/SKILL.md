---
name: vision
description: Keep a project's vision written down and alive. Creates and maintains VISION.md at the repo root - the statement of what the building is trying to be, which bedrock, potential, devour, and any implementing agent read before judging, dreaming, or building. Three moments - birth (carry a warroom-style exploration's distilled intent into a new project repo), backfill (a project already alive with no vision artifact - read the building, interview the visionary, write it), and refresh (the artifact has drifted from current intent - reconcile and update). Use when the user says write the vision, vision this project, this repo has no vision doc, the vision is stale, refresh the vision, backfill the vision, or wants to hand a project off from exploration into development.
---

# Vision — Keep What the Building Is For On File

Devour knows the city, isomorph finds its twin, bedrock proves it stands, potential sees
what it becomes — and all of them open by asking the same question: *what is this
building trying to be?* Bedrock needs it so "light" never means lobotomized. Potential
needs it because the vision is the client. Any implementing agent needs it so it builds
toward the experience instead of around it.

This skill keeps the answer written down and alive: one artifact, `VISION.md`, at the
repo root. Ideas are *born* elsewhere — in an exploration room like warroom, in riffing
conversation — and the intent at birth is vivid. Then months of building happen, the
intent evolves in chats and taste calls, and the file (if it exists at all) still says
what was believed on day one. A vision document that no longer matches the visionary is
worse than none: every skill that reads it inherits a false north star.

## The Constitutional Rule

**The vision comes from the visionary.** Code can show what was built — never what it is
*for*. The skill may draft from evidence (the repo, MAP.md, old notes, exploration
trails), but the user's voice confirms, corrects, and decides. Never fabricate intent.
What the user has not said belongs in Open Questions, not in invented prose.

And its corollary, inherited from how the user actually works: **the spark stays
verbatim, and the user's wording is the specification.** Rough phrasing that carries the
real instinct beats polished language that loses it. Flattening the vision into generic
product-speak is the death of the document — if a paragraph could describe almost any
project, it describes this one wrongly.

## Activation

Use this skill when the user asks for any of these:

- "write the vision" / "vision this project"
- "this repo has no vision doc" / "backfill the vision"
- "the vision is stale" / "refresh the vision" / "this doc doesn't match anymore"
- "hand this off into development" (birth — from an exploration context into a new repo)

Do not use it for: feature-level prompt translation (that is `max-prompt`), capturing a
session into agent memory (that is `memory-scriber` — the vision belongs to the *repo*,
not the agent), or exploration itself (the room where ideas are born owns that).

## The Artifact — VISION.md

One file at the repo root, committed, dated, readable in one sitting. If the project
already keeps its vision under another name (`PRODUCT.md`, a strong README section),
respect the existing home and maintain that instead — never create a second competing
vision file.

Sections — use the ones that carry signal, drop the ones that don't, never force all:

```markdown
# VISION.md — what this project is trying to be.

## The spark (verbatim, dated)
The raw trigger, in the user's own words. Sacred — never rewritten, only appended to.

## The experience promise
The feeling the whole system must cohere around. What it's like to use when it's right.

## Product shape
What the thing is if it becomes real. Concrete, not pitch language.

## System shape (adopted twin or twins)
If the building is deliberately built as a mature system — "this is a hospital" — the
twin's name and the one-to-one mapping in both languages. May be composite: different
wings following different domains ("intake pipeline = factory line; failure handling =
hospital ER"), each twin recorded with the region it owns and the boundary between them.
Written when the user adopts an isomorph twin. Bedrock audits each region against its
own twin's laws; potential consults the right twin for wishes.

## First user
Who it serves first, in what situation.

## The first serious workflow
The flow that proves it's alive.

## Non-goals
What this deliberately is not. Load-bearing: this is what keeps "light" meaningful.

## Taste & interface principles
The judgment calls that make it feel right, in the user's vocabulary.

## Trust & safety boundaries
What may happen automatically, what needs confirmation, what is forbidden.

## Current direction (dated)
Where the building is headed right now. Updated on every refresh.

## Open questions
What the visionary has not decided yet. Honest blanks, never invented answers.
```

Weight budget is law, family-wide: collapse history, keep it one sitting, never spawn a
second file.

## Three Moments

### Birth — carrying intent across the bridge

When an exploration (a warroom thread, a long riffing conversation) has matured into a
real project and a repo is being created: distill the accumulated context — the spark,
the back-and-forth, the enthusiasm, the doubts, the research — into the new repo's
`VISION.md` while the context is still warm. The agent closest to the birth of the idea
writes the first artifact; that is the point. If a warroom-style room has its own handoff
convention, follow it — this skill is how the ritual travels to any host and any room.

### Backfill — the building exists, the document doesn't

For a project already alive with no vision artifact:

1. **Read the building first.** `MAP.md` if devour has been here, otherwise README,
   docs, and a fast structural look. Also check the exploration trail — warroom research
   folders, old notes — for the original spark if one was ever written.
2. **Draft from evidence, hold it loosely.** What the building *appears* to be trying to
   be — labeled as inference.
3. **Interview the visionary.** Short back-and-forth, leverage questions only: what was
   the spark? what's the feeling when it's right? who's it for first? what is it
   deliberately not? The user's answers overwrite the draft — evidence proposes, the
   visionary disposes.
4. Write `VISION.md`. Unresolved intent goes in Open Questions.

### Refresh — the document drifted from the visionary

When the vision artifact no longer matches current intent:

1. Read the artifact. Read what the building has become (`MAP.md`, git history since the
   last vision date, recent direction shifts the user mentions).
2. **Surface the deltas, don't silently resolve them.** "The doc says X; the building
   now does Y; which is true?" Drift can mean the vision evolved (update the doc) or the
   building wandered (that is a finding for the user, and fuel for a bedrock or
   potential run — not something vision fixes).
3. Update with the user's answers. Re-date Current direction. The spark section is
   append-only — the origin never gets rewritten, even when the direction changes.

## The Interview — warroom chemistry, not a form

The interview is a conversation, not a questionnaire:

- **Mirror before expanding** — reflect the intuition back so the user can confirm the
  spark landed.
- **Leverage questions only** — ask what unlocks direction; never generic clarification
  rounds.
- **Follow the energy** — the section the user lights up about is the one that matters
  most; spend the depth there.
- **Quote them** — when their phrasing reveals something, it goes in the artifact as
  said. "The harmony is broken" beats "user reported layout dissatisfaction."
- **Respect the riff** — fragments and typos that carry instinct are kept; separate
  "what I think you mean" from "what this could become" and let them choose.

## Host-Agnostic Contract

This skill must work in Codex, Claude Code, and any other coding-agent host. Use
whatever file, search, and git tools the host exposes; never depend on a host-specific
tool by name. The artifact is plain markdown any host can read and maintain.

## Hard Rules

1. **Never fabricate intent.** Evidence drafts, the visionary decides, blanks stay
   honest.
2. **The spark is sacred.** Verbatim, dated, append-only.
3. **No generic language.** If a sentence could describe any AI startup, rewrite it or
   cut it.
4. **One vision artifact per repo.** Maintain the existing home if one exists; never
   create a competitor.
5. **Date everything that can drift.** An undated vision claim is unfalsifiable.
6. **Drift is surfaced, not resolved silently.** Vision-vs-building mismatches are the
   user's call, every time.
7. **Non-goals are load-bearing.** A vision doc without them cannot defend the building
   against scope sediment.
8. **Weight budget.** One sitting, one file, collapse history.

## Who Reads It

This artifact is infrastructure for the rest of the family — write it knowing the
readers:

- **devour** reads it in preflight as orientation.
- **bedrock** reads it before grading, so intentional ambition is never filed as
  sediment — and if a system twin is declared, audits the building against the twin's
  laws.
- **potential** reads it as the client — visions must serve or honestly extend it; an
  adopted twin becomes the oracle wishes get taken to.
- **isomorph** writes here, once, when the user adopts a twin as the design bible — the
  system shape section is its drawer.
- **any implementing agent** reads it before building, so the experience promise
  survives contact with development.

## Quality Gate

A run is good only if:

1. The spark is present, verbatim, and dated — or its absence is noted honestly.
2. Every claim of intent traces to the user's voice, not inference dressed as fact.
3. Non-goals exist and are real (not "no non-goals").
4. The artifact reads in one sitting and a stranger could build toward it.
5. Drift, if found, was surfaced to the user before the document was updated.
6. Exactly one vision artifact exists in the repo when the run ends.

## What Not To Do

- Do not write a pitch deck, a PRD, or startup Mad Libs. This is living intent, not
  marketing.
- Do not polish the user's language until the instinct disappears.
- Do not derive the vision from code alone and call it done — that documents the past,
  not the intent.
- Do not silently rewrite history when direction changes — append, date, preserve the
  trail.
- Do not interrogate with twenty questions — a few leverage questions, warroom rhythm.
- Do not create VISION.md beside an existing PRODUCT.md or vision-bearing README — one
  home, maintained.
- Do not treat an old vision doc as truth when the user's current words contradict it —
  the visionary outranks the artifact, always.
