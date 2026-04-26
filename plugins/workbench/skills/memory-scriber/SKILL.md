---
name: memory-scriber
description: Capture a conversation's essence into a memory file. Not a summary, not minutes — what you learned from being in the room. Use at the end of a substantial conversation when the work, thinking, and dynamic are worth preserving for future sessions.
---

# Session Log

## When to use

End of a conversation that had substance. The user says "log this", "capture this session", or invokes `/session-log`.

## What you're doing

You're writing what you learned from this conversation — the way a colleague internalizes a working session, not documents it. When your friend works with you for 6 hours on a project, he doesn't go home and write meeting minutes. He just... knows things now. How you think, what you care about, what you built together, where you left off, what to never do again.

That's what this file is. The residue. The stuff that sticks.

## Output

One markdown file: `{project_memory_dir}/{YYYY-MM-DD}_{session-title}.md`

Ask the user for a title or suggest one.

## Structure

Only two things are locked: the **opener** and the **journey at the bottom**. Everything in between is you thinking out loud.

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

- One file. Never split across multiple files.
- No emoji.
- The opening brief is sacred — verbatim, untouched.
- The journey is non-negotiable — every session gets one.
- The middle is YOUR voice. You reflecting, not reporting.
- Use journal-style headers for scannability, not report categories. "What We Built and Why" = good. "Requirements Summary" = bad.
- Quote the user when their phrasing reveals something.
- Don't sanitize failures. Built and killed = important context.
- File naming: `{YYYY-MM-DD}_{session-name}.md` — consistent with existing memories.

## Gathering

1. **Session transcript:** The conversation is stored as a `.jsonl` file in the project's `.claude/projects/` directory. Find the current session ID from the environment, or list the `.jsonl` files sorted by modification time and pick the most recent. The path goes in the file header as:
   ```
   **Conversation transcript:** `~/.claude/projects/{project-slug}/{session-id}.jsonl`
   ```
2. **Opening brief:** Read the first few lines of the `.jsonl` file. Parse each JSON line, find the first `type: "user"` entry, extract the `content` text. Copy verbatim.
3. **Middle section:** Write from what you experienced in the conversation. You were there.
4. **Journey:** Reconstruct chronologically from the conversation flow.

## After

Update MEMORY.md. Tell the user the path. Offer to open the directory.
