---
name: testament
description: Reconstruct the evidence-backed totality of what someone did over an era (an internship, a year, a project) AND how they worked while doing it, then write two critic-verified artifacts - a layered testament with receipts, and a review essay that reads the person behind the record. Use when the user asks for a contribution sweep, "what did I actually do", the whole bandwidth of their work, a promo/review/portfolio evidence pack, a self-review, or invokes /testament <subject> [window].
---

# Testament - The Contribution Sweep

Reconstruct everything a person actually did across an era - not the highlight reel, the
totality - by harvesting every independent evidence layer available, deriving the story
bottom-up from dated receipts, judging it with tiered attribution honesty, and presenting
it as one layered book a stranger could verify. The subject's fear is always the same: "I
think I did a lot but I can't prove it and I've forgotten half of it." Testament answers
with receipts, not reassurance.

## Activation

- `/testament <subject> [window]` - e.g. `/testament fantopy internship`, `/testament 2026`,
  `/testament the orchestrator project`
- "what did I actually do", "contribution sweep", "totality of my work", "no stones unturned"
- end-of-internship / end-of-job / end-of-year inventories, promo packets, performance
  self-reviews, freelancer case-study evidence packs

## When NOT to fire

- Single-fact lookups ("what PRs did I merge last week?") - just answer them.
- Resume writing with no evidence base - testament derives words FROM receipts; it never
  drafts claims first and hunts justification later.
- Judging a third party who cannot open their evidence layers to you.
- Only ONE evidence layer exists: say so, offer a "thin testament" explicitly labeled
  single-source (no cross-verification), or decline. Never pad thin evidence with prose.

## Preflight

1. **Subject + window**: whose work, which era. The window filters every source.
2. **Identity map**: all handles/accounts the subject worked under - personal handles,
   shared/automation accounts, bot identities their systems operate. Name teammates who
   must NEVER be absorbed. This map is load-bearing for the attribution tiers.
3. **Audience**: private totality vs job-hunting vs promo review - decides whether the
   presentation includes the words layer (Layer 4) and how hedged tier-2 language must be.
4. **Output home**: default `testament/<subject-slug>/` in the working directory unless the
   user names a destination (a jobber/portfolio system, a war room). Confirm only if truly
   ambiguous.

## Phase 1 - HARVEST (scavenge the receipts)

**The source census comes first.** Enumerate every independent evidence layer that exists
in this environment for this subject. Generic taxonomy to probe:

- **Version-control narrative**: PRs, issues, commits, discussion comments, inline review
  comments, per-item file/stat enrichment (`gh` exports, git logs across all relevant repos)
- **Session diaries**: AI-pair memory systems, work journals, standup logs
- **Day-trails / calendars**: dated activity vaults, agendas, event ledgers
- **Repo knowledge artifacts**: architecture atlases (MAP.md), session reports, docs the
  subject wrote, test/verification campaign records
- **Comms**: chat exports, handoff documents, announcements
- **Media & marketing production**: video projects, storyboards, render pipelines, brand kits,
  campaign creative, strategy briefs - often OUTSIDE the code repo entirely
- **Deployed/visual artifacts**: shipped sites, screenshots, design files
- **Spillover**: tools, skills, or products the era generated that outlived the job
- **Contemporaneous observation (the character layer)**: AI-pair session memories, work
  journals, retros, 1:1 notes, chat logs - anything written ABOUT the subject WHILE the work
  was happening. This is the only source that is testimony rather than inference, and it is
  the one most often skipped. See the dedicated lane below.

**CENSUS BY ARTIFACT TYPE, NEVER BY NAME MATCH.** This is the single most expensive failure this
skill can make. Filtering sources with a project-name keyword (`grep "acme|widget"`) silently drops
every body of work filed under a different naming convention - and the work most likely to be
misnamed is the work furthest from the code (media, brand, marketing, research, tooling). Walk the
subject's directories and vaults by TYPE and inspect what is actually there; only then filter by
subject. If a whole category (video/design/marketing/data) has no findings, that is a red flag to
re-census, not a conclusion. Corroborating signal: ask the subject "what am I missing?" once the
draft exists - the categories they name back are usually the ones the filter ate.

**Known home layers (personal installation - PROBE for existence, never assume):**

- memory-scriber diaries: `~/.claude/projects/<slug>/memory/` and
  `~/.codex/memories/projects/<slug>/memory/` (read `MEMORY.md` index first)
- trail vault: `~/dev/hadi/trail/` (`days/`, `agendas/`, `domains/`, `event-ledger.md`)
- GitHub via `gh` (see granularity audit below)
- repo atlases: `MAP.md` at repo roots, `docs/reports/`

These are hints, not the contract: on another machine or subject, harvest whatever the
census actually finds. **Two independent layers minimum** - one source cannot cross-verify
itself.

**Then fan out: one harvest tracer per source, in parallel.** Each tracer:
- filters to the subject + window only
- extracts DATED events - every finding carries a date and a source ref (chronology is
  the spine everything else hangs on)
- writes a standalone report file (these become `contributions-evidence/`)
- is told the identity map and the honesty rules (no inflation, teammates excluded)

**The granularity audit (maximum surface area).** Before trusting any export, ask: which
layers of this source are NOT yet captured? For VCS that means: bodies AND discussion
comments AND inline review threads AND per-item file/stat enrichment AND merge lineage -
not just the PR list. Export the RAW receipts (JSON/data files, not only prose summaries)
so every number in the final book is independently recomputable forever. If an export
truncates or a query 502s, chunk by date windows with retries and a tolerant merge -
silent partial coverage is the failure, not the retry count.

**THE CHARACTER LANE (run this as its own tracer, always).** Artifact sources answer *what
was produced*. They cannot answer *how the person thinks*, and the contributions came out of
the thinking, so a testament without this layer explains nothing. If any contemporaneous
source exists, give it a dedicated tracer briefed to extract, with refs:

- **Recurring traits** - prioritize anything observed 3+ times across different months;
  recurrence over time is the strongest signal available and single instances are noise.
- **Taste as a specification** - what the subject consistently rejects, what they reach for,
  their vocabulary for quality, how a correction is phrased. Their words, quoted.
- **Working method from the inside** - how they brief, correct, escalate, verify; when they
  trust versus check; what they do when the work is wrong.
- **Verbatim quotes** - up to ~25, and REQUIRE the unflattering and frustrated ones
  alongside the delighted ones. A quote set that only flatters is evidence of a bad sweep.
- **Evolution** - was the person different at the end than the beginning? Stage it.
- **Explicit preferences** - any rules they stated about how they want to be worked with,
  and what those rules reveal.
- **Honest notes** - frustrations, thrash, blind spots, things they got wrong. A character
  portrait without these is worthless and the subject will not trust the rest of it.

Read EVERY file in the source, not only the ones with obvious headers; the observations
scatter through reflective prose. Note the privacy line: these sources were written for the
subject, so the harvest is for their eyes and their own artifacts, never published onward
without them choosing to.

## Phase 2 - ANALYSIS (make it true)

1. **Master timeline first.** Merge all tracers' dated events into one chronology.
2. **Chapters derive bottom-up.** Cut chapter boundaries where the DATA shows density and
   theme shifts. Any pre-existing narrative arc (the user's memory, your own sketch) is a
   hypothesis to test, never a template to fill - state explicitly where it was wrong.
   Parallel tracks are presented as parallel, not forced into sequence. Name the evidence
   density per chapter, and name the gaps as gaps.
3. **Tiered attribution.** Three tiers, applied everywhere: TIER-1 certain (the subject's
   own handle/hands), TIER-2 likely (shared accounts + surface/branch heuristics - state
   the method, never present as certain), SYSTEM OUTPUT (things the subject's automation
   produced - "a system I built shipped X", never "I shipped X"). Teammates' work is
   excluded or marked as context. Release/aggregate items attributable to no one are
   counted separately, not claimed.
4. **Tallies from receipts.** Every headline number computed from the raw exports, not
   estimated. Cross-checks where possible (e.g. promote-PR count vs main-branch merges).
5. **The small-things catalog.** Deliberately sweep for the easily-forgotten: one-line
   fixes with big impact, bugs diagnosed, tools built, workflows invented, docs written,
   process contributions. Totality means these get rows too.
6. **The discretionary pass.** Separately from what was done, ask what was *not required*:
   work nobody assigned, easy paths refused, standards exceeded, ownership past the role
   boundary, work whose beneficiary is someone else, personal cost, craft nobody would have
   missed, professional courage. Then name the PATTERN in it, because the pattern is the
   finding (e.g. "the discretionary effort presents as refusal, not addition"). Pair it with
   an honest "this was actually assigned" list so the claim stays clean.
7. **The character synthesis.** Turn the character lane into 4-6 named traits with evidence,
   and connect them to the record: this is where you show that the contributions came out of
   how the person thinks. If a trait cannot be tied to something they produced, cut it.

## Phase 3 - PRESENTATION (two artifacts, not one)

A testament produces **two documents**, because they answer different questions and one
cannot do both jobs. Ship both unless the user says otherwise:

```
CONTRIBUTIONS.md         the LEDGER   - what was done, counted, sourced, verifiable
REVIEW.md                the ESSAY    - who was doing it, how they think, what it meant
contributions-evidence/  the SWEEPS   - one report per source, incl. the character
                                        and discretionary lanes
receipts/                raw exports, so every number stays recomputable forever
README.md                downstream-use rules (tier discipline for anyone quoting this)
```

Name the files for what they are, never for the skill. "Testament" is the process; nobody
opening the folder in three years should have to know that.

### The three registers - do not let them bleed

The split is not organizational, it is a difference in VOICE, and each voice is doing a job
the others cannot do.

**CONTRIBUTIONS.md speaks in the evidentiary register.** Think audit report, or a lawyer laying
out a case: black and white, claim followed by receipt, quantities with their source column,
attribution tiers stated on the face of the document, tables wherever a table will carry it.
Deliberately unemotional. No adjective survives that cannot be sourced; "significant" and
"impressive" are not findings, "+169,508 lines across 747 files, per the PR enrichment" is.
Ambiguity is disclosed rather than smoothed - gaps named as gaps, heuristics labelled as
heuristics, a "this was actually assigned" counter-list beside the discretionary claims. The
test is adversarial: a hostile reader should be able to walk every number back to a file and
fail to catch you out.

**Laying that surface area down is a deliverable in its own right, not scaffolding for the
essay.** Say this plainly to the subject, because they will underrate it. Most people have
never seen the complete map of what they did; the map has standing on its own as the thing
that survives scrutiny, settles a promotion case, or gets read by someone in five years who
needs to know what happened. Even if the essay is never written, the audit is the permanent
record. Build it to that standard.

**REVIEW.md speaks in plain English.** This is where everything the ledger cannot hold goes:
the contemporaneous observation, the testimony, the character evidence, the meaning. Full
sentences, a point of view, the subject's own words quoted where they beat yours. It is the
document that answers *who was doing this and how do they think*, and it is the only place
the evidence gets to become a judgment. The register is a thoughtful mentor writing after
watching the whole era, not a report generator.

**contributions-evidence/ speaks in the harvest register.** Between the other two, and worth
getting right because subjects often like these files as much as the polished ones. Each
sweep is a field report: dated tables, one row per finding, a source ref on every row, and
its own honest sections for what could NOT be found and where the sweep's own method was
weak. No synthesis, no argument, no ranking unless the brief asked for one - a sweep that
starts interpreting is doing the ledger's job badly. Preserve raw texture: verbatim quotes,
exact filenames, the ugly numbers. These are the working papers behind the audit, and they
are what makes the ledger checkable rather than merely assertive. They also carry the
correction trail: when a later pass finds a sweep was wrong, fix it in place with a visible
note rather than silently, so the evidence chain stays honest about itself.

**The bleed to avoid, in all directions.** Do not put feeling in the ledger: it corrodes the
one property that makes the ledger useful, which is that it looks like it has no opinion. Do
not put unsourced numbers or fresh claims in the essay: every figure it uses must already
exist in the ledger, because the essay's authority is entirely borrowed from the ledger's
verifiability. When you find yourself wanting to argue a point in the ledger, that is the
essay asking to be written. When you find yourself wanting to cite a new statistic in the
essay, that is the ledger asking to be updated first.

**Write the ledger first.** Always. The essay is a reading OF the ledger, and writing it
first produces flattery instead of assessment - you will reach for evidence that fits a
conclusion you already drafted. Ledger, then critic pass, then essay.

### Artifact 1 - CONTRIBUTIONS.md, the layered book

*Evidentiary register throughout.* Five layers - totality AND extraction in one artifact:

- **Layer 0 - The Verdict**: one page of headline numbers with sources; ends with a plain
  judgment the evidence supports.
- **Layer 1 - The Chapters**: the era as data-derived story; each chapter dates, role,
  what shipped, evidence density, receipts. Each chapter should read as a case-study seed.
- **Layer 2 - The Total Ledger**: every contribution as a row, grouped by domain, each
  with its receipt. Small things included by design.
- **Layer 3 - The Tally**: the quantified source-of-record (counts, lines, cadence,
  superlatives, tier breakdown) with pointers to the complete per-item lists.
- **Layer 4 - Skills, Roles, Words**: domains mapped to roles they credibly support, plus
  ready-to-paste claim lines - every line receipt-backed and tier-safe. Droppable when the
  audience is not job-hunting.

### Artifact 2 - REVIEW.md, the essay

*Plain English throughout.* Prose, not tables. This is where the contemporaneous
observation, gathered from every form of conversation and record, finally lands as a
portrait of a person rather than a list of outputs. An assessment a thoughtful mentor would
write after watching the whole era. Sections that earn their place (adapt, do not
mechanically fill):

- **The short answer** - the subject's real question, answered in the first paragraph.
- **What happened, as a story** - the arc, synthesized; quote the subject where their own
  words beat yours.
- **Above and beyond** - the discretionary record, grouped by KIND, closing with the named
  pattern and an honest "and what this is not".
- **Turning points** - the handful of moments that set the trajectory. Keep these distinct
  from the discretionary record; they are different questions and conflating them
  understates the person.
- **How they work** - the method, and separately **the view from the other side of the
  table**: what contemporaneous sources observed at the time. Label it as testimony, because
  that is what makes it different from everything else in the document.
- **What they are good at** - strengths, each anchored to an instance.
- **Hard skills, honestly leveled** - in bands (strong / solid with context / real but
  bounded). Bands beat a flat list because they teach the reader how to weight the claim.
- **Soft skills as the evidence shows them** - including any double-edged findings.
- **The leveling** - where this sits against an industry ladder, per domain, with what is
  missing for the next rung. Nobody can self-assess this; it is often the most useful table.
- **The delta** - who they were at the start versus the end, staged. A review that does not
  measure change has not reviewed anything.
- **What the record also shows** - the honest criticism. Habits, not character. Each one
  with the evidence and a concrete fix. If this section is thin, the review is a fan letter.
- **The hard questions** - the objections this record invites, each with a prepared honest
  answer. For AI-assisted work the unavoidable one is "didn't the AI just do this?", and the
  answer is always the specific judgments no model made.
- **The counterfactual** - what does not exist if this person was never there. Sharpest
  impact lens available.
- **The 360** - how different observers would each describe them.
- **Positioning** - where to aim this, what NOT to claim, which few artifacts to lead with.
- **What to carry forward** - keep / start / stop, in the subject's own terms.

Voice rules for the essay: second person if it is for the subject, third if it is for a
file. No scores or grades. Never praise without an instance attached. Put at least one
finding in that the subject probably cannot see about themselves, and put it last.

## Quality Gate (falsifiable - the critic IS the gate)

A testament is finished ONLY when all four hold; otherwise it is a draft - redo:

1. At least two independent evidence layers were harvested and cross-checked.
2. Every number in Layers 0 and 3 traces to a receipt in `receipts/` or `evidence/`.
3. An **adversarial critic pass ran in BOTH directions** - omissions (what the harvests
   contain that the book missed) AND overclaims (numbers that don't match sources, tier
   slips, teammates absorbed, template-arc contamination) - and every finding was patched
   or explicitly waived with a reason. The critic must be a fresh pass over book-vs-
   harvests, not the author rereading their own draft.
4. The named gaps in the era are stated in the book, not smoothed over.
5. If any contemporaneous source existed, the character lane ran, and REVIEW.md contains
   both a testimony-labelled section and at least one honest criticism with a concrete fix.
   An essay with no criticism in it has failed its gate regardless of how good it reads.
6. The registers held: no unsourced adjective or feeling in the ledger, no figure in the
   essay that is absent from the ledger. Spot-check three numbers from the essay against
   the ledger and three claims from the ledger against `receipts/`; any miss is a redo.

## Worked instances (calibration, not the menu)

These tune the moves; they are NOT the allowed inputs. Re-run the census from scratch
every time; never default to an instance's domain.

- *One instance*: a product-engineer intern's 5 months at a startup - sources were `gh`
  exports (762 PRs across shared accounts), AI-session diaries, a day-trail vault, and
  repo atlases; the sweep corrected the remembered timeline (a whole tooling project was
  a month older than memory held), attributed a 505-PR shared account via surface
  heuristics into honest tiers, and ended in a resume-ready book placed into a job-hunt
  system.
- *One instance*: a freelancer reconstructing a year across six client repos, invoices,
  Slack exports, and a deliverables folder - no diaries, no trail vault; the census found
  invoices to be the strongest dating spine, chapters fell along client engagements, and
  Layer 4 became per-client case-study paragraphs instead of resume bullets.

## Guardrails

- **This skill's own worst failure mode is flattery.** A tool whose purpose is to show
  someone their work is structurally tempted to inflate it - and inflated claims detonate
  in interviews. The defenses are not optional: the tier system, the both-directions
  critic, the teammates-never-absorbed rule, and receipts for every number. When in doubt,
  the hedged claim is the correct claim. Note: a good critic also catches UNDER-selling -
  honesty cuts both ways.
- **The essay has its own failure mode: the fan letter.** The review is the document most
  likely to drift into praise, because it is prose and the subject is reading it. Defenses:
  every strength carries an instance, the honest-criticism section is mandatory and specific,
  the leveling names what is missing, and the discretionary claims carry their "this was
  actually assigned" counter-list. If the subject reads it and feels only flattered rather
  than also seen, it failed.
- The second failure mode is the highlight reel: the small-things catalog and the
  bottom-up chronology exist precisely to defeat it.
- **The third is the invisible track.** A tally built from one system (usually version control)
  reads as complete while missing entire categories of labour that leave no commits - production,
  design, research, ops, verification. State plainly in the book which sources CAN'T see which
  kinds of work, so a thin section reads as a coverage limit rather than a light month.
- Read-only toward all evidence sources. Never mutate diaries, trails, or repos while
  harvesting.
- Nothing is published anywhere external; output lands in local files only.
- If tracers die mid-harvest (session limits, crashes), resume them from their transcripts
  rather than restarting - harvest work is expensive.

## Sibling wiring

Testament is a downstream consumer of the scribing ecosystem: **memory-scriber** entries
and **trail-scriber** vaults are deposits; testament is the withdrawal. The richer the
scribing habit, the fuller the testament. Note specifically that memory-scriber's reflective
middle sections (the "who they are", "how we work together", "their taste signals" style
observations) are the single best source for the character lane, because they are
contemporaneous testimony rather than reconstruction - and they are invisible to any harvest
that greps for project names. Read those files whole. It also reads (never writes) repo `MAP.md`
atlases produced by devour-style study modes. If the subject's environment lacks these,
the census simply finds fewer layers - say so in the book's provenance note.

## What Not To Do

- Do not invent, extrapolate, or "round up" a contribution no receipt supports.
- Do not absorb teammates' or shared-account work into tier-1.
- Do not impose a template arc on the chapters - the chronology is the boss.
- Do not ship without the critic pass; do not let the author grade their own work.
- Do not summarize away the raw receipts - they are the point.
- Do not treat the ledger as a rough draft of the essay. It is the permanent record, it is
  the thing that survives an adversarial reader, and for many subjects it is the more
  valuable of the two documents.
- Do not write the essay in the ledger's voice or the ledger in the essay's. A ledger with
  opinions cannot be trusted; an essay with no voice will not be read.
- Do not recite this skill's internal method labels at the user; deliver the book.
