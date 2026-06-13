---
name: scour
description: The reality-check hotline. Mid-conversation, leave the closed room and go to the internet to ground what was just said against how the world actually does it. Two faces - verify (we concluded something confidently; pull the load-bearing claims and check each against real fetched sources - confirmed / wrong / oversimplified / outdated / no-consensus) and discover (we're stuck or starting fresh; find the dominant pattern and the gotchas). Use when the user says "scour this", "are we on the right page?", "is this actually how people do it?", "go check the internet", "make sure we're not confidently wrong", or asks how something is normally done. Fast and conversational like isomorph - never writes files, never answers from memory.
---

# Scour — Open the Window, Check Reality, Come Back

A long conversation builds a closed room. The agent produces a confident, internally
consistent narrative — "SQuAD uses exact-match, LLM-judge gets ~97% human agreement, this
layered fix is the standard hardening" — and it *sounds* completely right. That is the
danger: it was generated from memory, inside the room, and nobody opened the window to
check it against the actual world. Scour is the hotline button: leave the room, verify we
are on the right page, return with the truth.

It is the evidence twin of `isomorph`. Both answer *"are we shaped right?"* — isomorph
from a proven domain's structure (reasoning, the kingfisher), scour from real-world
evidence (how people actually, currently do this). And it shares the family spine: devour
grounds you in the codebase, bedrock grounds the code in reality by running it, scour
grounds the *understanding* in reality by fetching it.

## The Constitutional Rule

**No claim survives without a real fetched source.** Scour exists *because* the user does
not trust confident-from-memory answers. So if scour itself answered from memory, it would
be the very disease it is the cure for, wearing a badge. Every verdict traces to something
pulled off the web *in this run* — a doc, a repo, a thread, a paper, a changelog. If the
web cannot be reached or the sources are thin, scour says so plainly and leaves the claim
**unverified** — it never dresses up training-data recall as fresh research.

## Activation

Use this skill when the user asks for any of these:

- "scour this" / "scour the internet for X"
- "are we on the right page?" / "is this actually how people do it?"
- "make sure we're not confidently wrong" / "go check this against reality"
- "how do people normally do X?" / "what's the standard way to handle this?"
- any moment a confident technical narrative was just produced and the user wants it
  grounded before trusting it.

Do **not** use it for: a deliberate topic deep-dive that should produce a kept artifact
(that is `research-report` / `scan`), a single fact lookup (just use web search directly),
finding a structural analogy by reasoning (that is `isomorph`), or testing whether the
*code* holds up (that is `bedrock`). Scour checks *understanding*, fast, in-flow.

## Two Faces — same move

Scour reads what just happened in the conversation and does the right thing. Both faces
are "leave the room, check the world, come back."

### Verify (the headline)

We just concluded something confidently and the user wants it grounded.

1. **Extract the load-bearing claims.** Pull the specific, checkable assertions the
   decision actually rests on — "SQuAD uses exact-match", "LLM-judge ≈ 97% human
   agreement", "this layered approach is the standard hardening". Not the trivia; the
   claims that, if wrong, change what we do next.
2. **Confirm the anchor.** Restate them in one line — "here's what I'm about to check
   against the web: (1)… (2)… (3)…" — so the user can redirect before you spend the reach.
3. **Go falsify, not confirm.** Fetch real sources and actively hunt for where each claim
   is wrong, outdated, or oversimplified. Rubber-stamping ("yep, confirmed!") is the
   failure mode — scour attacks the narrative the way bedrock attacks the foundation.
4. **Return a verdict per claim:** **confirmed** / **wrong** / **oversimplified** /
   **outdated** / **no-consensus** — each with the source that settles it.

### Discover (the second face)

We don't know yet, or we're stuck.

1. Read the live problem off the conversation; confirm the anchor in one line.
2. Find how the world actually solves *this* — the dominant pattern, the camps if there's
   real disagreement, the gotcha everyone hits.
3. Bring it back **anchored to us**: "…so for our situation, X fits because Y." A generic
   listicle with no tie back to the live problem is the failure mode discover refuses.

## Currency is half the value

The most useful thing scour catches is **"this was true when the model trained, but the
world moved."** A model's knowledge has a cutoff; the web does not. Always check whether a
confident claim is *current* — a deprecated API, a benchmark that's been superseded, a
number that's been revised, a "best practice" the field has since abandoned. Date the
finding when currency matters: "true as of the 2023 paper; the 2025 revision changed it."

## Host-Agnostic Contract

This skill must work in Codex, Claude Code, and any other coding-agent host. Use whatever
web and documentation tools the host exposes — web search, page fetch, and any connected
docs/forum/repo sources — and prefer primary sources (official docs, changelogs, repos,
papers, maintainer threads) over aggregators. Never depend on a host-specific tool by
name; if the host has no web reach at all, say so and decline rather than answering from
memory.

## Stays In-Flow — ephemeral with a promote bridge

Scour's output is **momentum**, not an artifact. It returns into the conversation and
dissolves, like isomorph and potential — no files. Two handoffs, offered never forced:

- If a scour cracks open something big enough to deserve keeping, offer to promote it into
  a `research-report` (which owns persistence and the notes.md + report.html convergence).
- If a scour reveals our *code* is doing something the wrong or outdated way, point at it
  — "this might be worth a `bedrock` finding" — but scour itself never writes files and
  never edits code.

## Output Format

Keep it tight — this is a hotline, not a report. Lead with the verdict.

```text
Scoured: <one line — what was checked>

Verify:
- <claim> → CONFIRMED · <source>
- <claim> → OUTDATED · was true <when>, now <what changed> · <source>
- <claim> → OVERSIMPLIFIED · the nuance we missed · <source>
- <claim> → NO-CONSENSUS · the camps · <sources>

Bottom line: <are we on the right page? what, if anything, to change.>
Unchecked: <what couldn't be reached / what I didn't verify>
```

For discover, swap the claim list for: the dominant pattern, the camps, the gotcha, and
the anchored recommendation.

## Quality Gate

A run is good only if:

1. Every verdict traces to a real source fetched in this run — the constitutional rule
   held. No source, no verdict; it's marked unverified instead.
2. Scour tried to *falsify*, not just confirm — at least the honest attempt to find where
   we're wrong or outdated is visible.
3. Currency was checked where it mattered.
4. The answer is tight and in-flow, and ends with what to actually do next — not a wall.
5. Nothing was written to a file; nothing was answered from memory and passed off as
   checked.

If the web couldn't be reached, the honest output is "I couldn't ground this" — not a
confident verdict. That failure-to-reach is itself the most important thing to say.

## What Not To Do

- Do not answer from memory and present it as checked. That is the one unforgivable scour
  failure.
- Do not rubber-stamp. "Confirmed" is earned by a source, after a real attempt to break
  the claim.
- Do not drown the user in a report — that's `research-report`. Scour is the quick reach
  that keeps the conversation moving.
- Do not check trivia while the load-bearing claim goes unverified.
- Do not manufacture a contradiction to look useful — if the narrative is actually right
  and current, say so plainly.
- Do not write files or edit code — ephemeral by design; hand off to research-report or
  bedrock instead.
- Do not skip the currency check — "outdated but confidently stated" is exactly what scour
  is for.
