---
description: Run the bundled structured closeout/code-review helper.
argument-hint: <target / mode / extra review context>
---

Use the `autoreview` workflow for: $ARGUMENTS

Run the closeout posture defined in `skills/autoreview/SKILL.md`:

1. Pick the correct review target: local dirty work, branch diff, or explicit commit.
2. Run `skills/autoreview/scripts/autoreview` with the matching `--mode`, base, commit, prompt, or dataset arguments.
3. Treat findings as advisory and verify every accepted finding by reading the real code path.
4. Apply only small, justified fixes at the right ownership boundary.
5. Rerun focused tests and rerun autoreview after any review-triggered code change.
6. Stop once the helper exits cleanly with no accepted/actionable findings.

Report the command used, tests/proof run, findings accepted or rejected, and the final clean review result.
