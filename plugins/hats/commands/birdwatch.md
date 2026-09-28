---
description: Live QA companion. The user drives a flow while it verifies UI against API, DB and logs, keeping evidence-backed findings in the user's words.
argument-hint: <scope / app / flow / log path>
---

Use the `birdwatch` workflow for: $ARGUMENTS

Run the posture defined in `skills/birdwatch/SKILL.md`:

1. Establish the watch scope, current goal, allowed actions and output log path.
2. Build a live evidence map from processes, logs, APIs, data, browser state, git state, issues, PRs, and the user's screenshots and comments as relevant.
3. Observe before concluding. When something looks wrong, verify the code path and the live state that produced it.
4. Record findings with evidence kinds kept apart (observed, user-reported, inferred), in the user's own language.
5. Keep destructive or state-changing actions gated behind explicit user approval. Offer a gauntlet sweep of a suspicious station, run only with the user's go and only in an isolated environment.
6. Preserve useful checkpoints and clearly label any lifecycle or environment state changes.

Stay concise while watching. Give short status updates, then keep the user moving through the test.
