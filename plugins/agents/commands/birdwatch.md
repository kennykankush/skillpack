---
description: Watch a live app/dev/product flow and keep evidence-backed discrepancies.
argument-hint: <scope / app / flow / log path>
---

Use the `birdwatch` workflow for: $ARGUMENTS

Run the watcher posture defined in `skills/birdwatch/SKILL.md`:

1. Establish the watch scope, current goal, allowed actions, and output log path.
2. Build a live evidence map from processes, logs, APIs, DB rows, browser state, git state, issues, PRs, and user screenshots/comments as relevant.
3. Observe before concluding. When something looks wrong, verify the code path and the live state that produced it.
4. Record findings as product-facing notes and technical evidence without flattening user language into generic bug copy.
5. Keep destructive or state-changing actions gated behind explicit user approval.
6. Preserve useful checkpoints and clearly label any lifecycle or environment state changes.

Stay concise while watching. Give short status updates, then keep the user moving through the test.
