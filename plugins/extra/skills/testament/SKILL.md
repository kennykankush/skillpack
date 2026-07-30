---
name: testament
description: Reconstruct the evidence-backed totality of what someone did over an era (an internship, a year, a project) and write it as a layered, critic-verified testament with receipts. Use when the user asks for a contribution sweep, "what did I actually do", the whole bandwidth of their work, a promo/review/portfolio evidence pack, or invokes /testament <subject> [window].
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
- writes a standalone harvest report file (these become the evidence folder)
- is told the identity map and the honesty rules (no inflation, teammates excluded)

**The granularity audit (maximum surface area).** Before trusting any export, ask: which
layers of this source are NOT yet captured? For VCS that means: bodies AND discussion
comments AND inline review threads AND per-item file/stat enrichment AND merge lineage -
not just the PR list. Export the RAW receipts (JSON/data files, not only prose summaries)
so every number in the final book is independently recomputable forever. If an export
truncates or a query 502s, chunk by date windows with retries and a tolerant merge -
silent partial coverage is the failure, not the retry count.

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

## Phase 3 - PRESENTATION (the layered book)

One master document (default `TESTAMENT.md`) plus `evidence/` (the harvest reports) plus
`receipts/` (the raw exports), and a README stating the downstream-use rules (tier
discipline for anyone transposing claims into resumes).

The book's five layers - totality AND extraction in one artifact:

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
scribing habit, the fuller the testament. It also reads (never writes) repo `MAP.md`
atlases produced by devour-style study modes. If the subject's environment lacks these,
the census simply finds fewer layers - say so in the book's provenance note.

## What Not To Do

- Do not invent, extrapolate, or "round up" a contribution no receipt supports.
- Do not absorb teammates' or shared-account work into tier-1.
- Do not impose a template arc on the chapters - the chronology is the boss.
- Do not ship without the critic pass; do not let the author grade their own work.
- Do not summarize away the raw receipts - they are the point.
- Do not recite this skill's internal method labels at the user; deliver the book.
