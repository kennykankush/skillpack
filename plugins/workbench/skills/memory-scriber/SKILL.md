---
name: memory-scriber
description: Capture a conversation's essence into Codex native memory. Not a summary, not minutes — what you learned from being in the room. Use at the end of a substantial conversation when the work, thinking, and dynamic are worth preserving for future Codex or Claude sessions.
---

# Session Log

## When to use

End of a conversation that had substance. The user says "log this", "capture this session", "memory-scribe this", or invokes `/session-log`.

## What you're doing

You're writing what you learned from this conversation — the way a colleague internalizes a working session, not documents it. When your friend works with you for 6 hours on a project, he doesn't go home and write meeting minutes. He just... knows things now. How you think, what you care about, what you built together, where you left off, what to never do again.

That's what this file is. The residue. The stuff that sticks.

## Output

Codex is the primary target.

Append to Codex native memory files:

1. `~/.codex/memories/MEMORY.md` — concise durable memory index for future Codex runs.
2. `~/.codex/memories/raw_memories.md` — full reflective session entry.

Create `~/.codex/memories/` if it does not exist.

Do not manually edit `~/.codex/memories/memory_summary.md` or `~/.codex/memories/rollout_summaries/`. Those are Codex-owned generated memory/consolidation artifacts.

For Claude Code or another legacy host, use the old portable fallback: one markdown file at `{project_memory_dir}/{YYYY-MM-DD}_{session-title}.md`, then update the project `MEMORY.md` if present.

Ask the user for a title or suggest one.

## Structure

Only two things are locked in the raw entry: the **opener** and the **journey at the bottom**. Everything in between is you thinking out loud.

### MEMORY.md entry

Append a compact entry near the top under a `## Human-authored session memories` section. If that section does not exist, create it below any existing title/frontmatter and above generated index material.

Keep this entry short enough for future Codex sessions to scan quickly:

```markdown
### {YYYY-MM-DD} — {Session Title}

Source: `~/.codex/memories/raw_memories.md#{anchor}`
Project: `{project path or "not project-specific"}`

{2-5 sentences: the durable thing future Codex should remember. Capture working style, decisions, taste signals, product direction, constraints, and where the thread left off.}
```

### raw_memories.md entry

Append the full entry to `~/.codex/memories/raw_memories.md`:

```markdown
---
session: {YYYY-MM-DD}-{session-title}
description: {One line — what happened and why it matters}
source: codex
project: {project path or "not project-specific"}
---

# {TITLE} — {Subtitle}
**Session date:** {YYYY-MM-DD}
**Conversation transcript:** `{path to transcript, or Codex current thread}`

## The Opening Brief (verbatim)

> {User's first message. Exactly as written. Their voice, typos, energy. Don't touch it.}

## What This Session Was

{One paragraph. The arc — what started as X became Y.}

---

{THE MIDDLE — Your reflection on the session.

Use journal-style section headers for scannability — things like "How We Work Together", "What We Built and Why It Evolved", "The Product Vision As I Understand It." These help future-you scan for relevance without reading 150 lines linearly.

But the content under each header should be loose, narrative, reflective. Not bullet databases. Not structured data. Write the way you'd think about it afterwards — what you learned, what surprised you, what their reactions revealed about how they think.

Good header examples (journal sections):
- "Who They Are (Through Working With Them)"
- "What We Built and Why It Evolved"
- "His Taste Signals"
- "The Product Vision As I Understand It"

Bad header examples (report categories):
- "Key Decisions"
- "User Preferences"
- "Technical Requirements"
- "Action Items"

Quote them when their words carry meaning. "The harmony is broken" tells you more than "user requested layout adjustment." Their vocabulary IS the specification.

Include what failed — what you tried that got rejected and why. Include the texture of the collaboration: were they leading or reacting? Did they riff on your ideas or redirect them? What product insights came out of UI arguments?

Think of it as: the conversation happened. You were there. Now you're writing what you took away from it — for yourself, so tomorrow you can walk in and pick up exactly where you left off.

Match the substance. Some sessions need 3 paragraphs, some need 30.}

---

## The Journey

{Numbered steps, chronological. What happened in what order. Each step: 1-2 sentences. Include the pivots. Include the user's exact words when they course-correct. This is the timeline that reconstructs the arc.}
```

### Legacy fallback file

Use this structure only when writing the Claude/project fallback file:

```markdown
---
name: {YYYY-MM-DD}-{session-title}
description: {One line — what happened and why it matters}
type: user
---

# {TITLE} — {Subtitle}
**Session date:** {YYYY-MM-DD}
**Conversation transcript:** `{path to .jsonl file}`

## The Opening Brief (verbatim)

> {User's first message. Exactly as written. Their voice, typos, energy. Don't touch it.}

## What This Session Was

{One paragraph. The arc — what started as X became Y.}

---

{THE MIDDLE — Your reflection on the session.

Use journal-style section headers for scannability — things like "How We Work Together", "What We Built and Why It Evolved", "The Product Vision As I Understand It." These help future-you scan for relevance without reading 150 lines linearly.

But the content under each header should be loose, narrative, reflective. Not bullet databases. Not structured data. Write the way you'd think about it afterwards — what you learned, what surprised you, what their reactions revealed about how they think.

Good header examples (journal sections):
- "Who They Are (Through Working With Them)"
- "What We Built and Why It Evolved"
- "His Taste Signals"
- "The Product Vision As I Understand It"

Bad header examples (report categories):
- "Key Decisions"
- "User Preferences"
- "Technical Requirements"
- "Action Items"

Quote them when their words carry meaning. "The harmony is broken" tells you more than "user requested layout adjustment." Their vocabulary IS the specification.

Include what failed — what you tried that got rejected and why. Include the texture of the collaboration: were they leading or reacting? Did they riff on your ideas or redirect them? What product insights came out of UI arguments?

Think of it as: the conversation happened. You were there. Now you're writing what you took away from it — for yourself, so tomorrow you can walk in and pick up exactly where you left off.

Match the substance. Some sessions need 3 paragraphs, some need 30.}

---

## The Journey

{Numbered steps, chronological. What happened in what order. Each step: 1-2 sentences. Include the pivots. Include the user's exact words when they course-correct. This is the timeline that reconstructs the arc.}
```

## Rules

- Codex native memory is the default. Use `~/.codex/memories/MEMORY.md` plus `~/.codex/memories/raw_memories.md`.
- Keep `MEMORY.md` compact. It is for durable retrieval signals, not the full session narrative.
- Keep the full narrative in `raw_memories.md`.
- Do not create custom per-project memory folders for Codex unless the user explicitly asks.
- For the legacy fallback, write one file and never split it across multiple files.
- No emoji.
- The opening brief is sacred — verbatim, untouched.
- The journey is non-negotiable — every session gets one.
- The middle is YOUR voice. You reflecting, not reporting.
- Use journal-style headers for scannability, not report categories. "What We Built and Why" = good. "Requirements Summary" = bad.
- Quote the user when their phrasing reveals something.
- Don't sanitize failures. Built and killed = important context.
- Legacy fallback file naming: `{YYYY-MM-DD}_{session-name}.md` — consistent with existing memories.

## Gathering

1. **Memory root:** In Codex, use `~/.codex/memories/`. If it does not exist, create it. If Codex memories are disabled in the host, still write the files and tell the user that future threads may need memories enabled to load them automatically.
2. **Session transcript:** In Codex, use the current visible thread as the source of truth unless a stable local transcript path is available in the environment. If no transcript file is available, put this in the raw entry header:
   ```
   **Conversation transcript:** `Codex current thread (transcript path unavailable)`
   ```
   For Claude Code legacy sessions, the conversation is usually stored as a `.jsonl` file in the project's `.claude/projects/` directory. Find the current session ID from the environment, or list the `.jsonl` files sorted by modification time and pick the most recent. The path goes in the file header as:
   ```
   **Conversation transcript:** `~/.claude/projects/{project-slug}/{session-id}.jsonl`
   ```
3. **Opening brief:** If a transcript file exists, read the first few lines of the `.jsonl` file. Parse each JSON line, find the first `type: "user"` entry, extract the `content` text, and copy it verbatim. If no transcript file exists, use the first user message visible in the current conversation and note that it came from visible context.
4. **Middle section:** Write from what you experienced in the conversation. You were there.
5. **Journey:** Reconstruct chronologically from the conversation flow.

## After

Tell the user the Codex native memory paths you updated:

- `~/.codex/memories/MEMORY.md`
- `~/.codex/memories/raw_memories.md`

If you used the legacy fallback instead, tell the user the fallback file path and whether you updated project `MEMORY.md`.
