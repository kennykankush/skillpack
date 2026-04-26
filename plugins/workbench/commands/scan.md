---
description: Quick research scan — replies with structured findings inline. No files written.
argument-hint: <topic description>
---

Invoke the `research-report` skill in **scan mode** for the topic: $ARGUMENTS

Lightweight pipeline:

1. Pick the right sources for the topic (same logic as official mode — marketing → Reddit/web/PH; engineering → GitHub/docs; etc.)
2. Research with the same depth and breadth as official mode — do not skimp on coverage
3. Reply directly in chat with this exact structure:

```markdown
## Key findings
- Bullet 1 (the punchline, not the setup)
- Bullet 2
- Bullet 3

## Sources
- [Link with one-liner of why it's relevant]
- [Link with one-liner of why it's relevant]

## Caveats / what I didn't check
- One-liner about gaps

---
*Want me to save this as an official research report? Reply yes and I'll promote.*
```

**Do NOT write any files** unless the user replies yes to the promote prompt. If they confirm, transition to official mode using the same findings:
- Run `scripts/bootstrap.sh`, `scripts/new.sh <umbrella> <slug>`
- Convert the chat findings into `notes.md`
- Synthesize `.build/report.qmd`
- Render with `scripts/render.sh <umbrella> <slug>` and open

Apply the same design rules as official mode: no emojis, declarative tone, sources cited inline.
