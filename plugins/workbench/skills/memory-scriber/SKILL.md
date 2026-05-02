---
name: memory-scriber
description: Capture a conversation's essence into the active host's memory directory. Supports Codex native memory and Claude Code project memory without assuming the two plugin runtimes share state.
---

# Session Log

## When to use

End of a conversation that had substance. The user says "log this", "capture this session", "memory-scribe this", or invokes `/session-log`.

## What you're doing

You're writing what you learned from this conversation - the way a colleague internalizes a working session, not documents it. When your friend works with you for 6 hours on a project, he doesn't go home and write meeting minutes. He just... knows things now. How you think, what you care about, what you built together, where you left off, what to never do again.

That's what this file is. The residue. The stuff that sticks.

## Host selection

Codex and Claude Code do not share one installed plugin runtime. This repo can ship one shared skill source, but each host installs and caches it separately:

- Codex plugin cache: `~/.codex/plugins/cache/...`
- Claude plugin cache: `~/.claude/plugins/cache/...`

Before writing memory, choose the active host:

- **Codex:** invoked from Codex, especially as `$workbench:memory-scriber`, or the current runtime exposes Codex context.
- **Claude Code:** invoked from Claude Code, especially through `/session-log`, `/workbench:*`, or Claude project/session paths.
- **Ambiguous:** ask the user whether to write Codex memory or Claude memory.

Write to exactly one host by default. Do not mirror between Codex and Claude unless the user explicitly asks.

## Output

Use the active host's memory store.

### Codex output

Append to Codex native memory files:

1. `~/.codex/memories/MEMORY.md` - concise durable memory index for future Codex runs.
2. `~/.codex/memories/raw_memories.md` - full reflective session entry.

Create `~/.codex/memories/` if it does not exist.

Do not manually edit `~/.codex/memories/memory_summary.md` or `~/.codex/memories/rollout_summaries/`. Those are Codex-owned generated memory/consolidation artifacts.

### Claude Code output

Write into the Claude project memory directory:

```text
~/.claude/projects/{project-slug}/memory/
```

Derive `{project-slug}` from the absolute project path by replacing `/` with `-`.

Example:

```text
/Users/hamulia/dev/ai-usage-app
-> ~/.claude/projects/-Users-hamulia-dev-ai-usage-app/memory/
```

Write:

1. `~/.claude/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md` - full reflective session file.
2. `~/.claude/projects/{project-slug}/memory/MEMORY.md` - concise project memory index.

Create the `memory/` directory and `MEMORY.md` if needed.

### Other hosts

Use the host's configured project memory directory if one exists. If no host-native memory path is known, ask the user where to write the memory instead of inventing a hidden global path.

Ask the user for a title or suggest one.

## Structure

Only two things are locked in the full entry: the **opener** and the **journey at the bottom**. Everything in between is you thinking out loud.

### Index entry

Append a compact entry near the top of the relevant index:

- Codex: `~/.codex/memories/MEMORY.md`
- Claude Code: `~/.claude/projects/{project-slug}/memory/MEMORY.md`

Use a `## Human-authored session memories` section. If that section does not exist, create it below any existing title/frontmatter and above generated index material.

Keep this entry short enough for future sessions to scan quickly:

```markdown
### {YYYY-MM-DD} - {Session Title}

Source: `{path to full entry}`
Project: `{project path or "not project-specific"}`
Host: `{codex | claude-code | other}`

{2-5 sentences: the durable thing future agents should remember. Capture working style, decisions, taste signals, product direction, constraints, and where the thread left off.}
```

### Full entry

For Codex, append this entry to `~/.codex/memories/raw_memories.md`.

For Claude Code, write this entry as `~/.claude/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md`.

```markdown
---
session: {YYYY-MM-DD}-{session-title}
description: {One line - what happened and why it matters}
source: {codex | claude-code | other}
project: {project path or "not project-specific"}
---

# {TITLE} - {Subtitle}
**Session date:** {YYYY-MM-DD}
**Conversation transcript:** `{path to transcript, or current visible thread}`

## The Opening Brief (verbatim)

> {User's first message. Exactly as written. Their voice, typos, energy. Don't touch it.}

## What This Session Was

{One paragraph. The arc - what started as X became Y.}

---

{THE MIDDLE - Your reflection on the session.

Use journal-style section headers for scannability - things like "How We Work Together", "What We Built and Why It Evolved", "The Product Vision As I Understand It." These help future-you scan for relevance without reading 150 lines linearly.

But the content under each header should be loose, narrative, reflective. Not bullet databases. Not structured data. Write the way you'd think about it afterwards - what you learned, what surprised you, what their reactions revealed about how they think.

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

Include what failed - what you tried that got rejected and why. Include the texture of the collaboration: were they leading or reacting? Did they riff on your ideas or redirect them? What product insights came out of UI arguments?

Think of it as: the conversation happened. You were there. Now you're writing what you took away from it - for yourself, so tomorrow you can walk in and pick up exactly where you left off.

Match the substance. Some sessions need 3 paragraphs, some need 30.}

---

## The Journey

{Numbered steps, chronological. What happened in what order. Each step: 1-2 sentences. Include the pivots. Include the user's exact words when they course-correct. This is the timeline that reconstructs the arc.}
```

## Rules

- Choose the active host first; write only to that host by default.
- Codex uses `~/.codex/memories/MEMORY.md` plus `~/.codex/memories/raw_memories.md`.
- Claude Code uses `~/.claude/projects/{project-slug}/memory/MEMORY.md` plus a dated file in that same `memory/` directory.
- Keep `MEMORY.md` compact. It is for durable retrieval signals, not the full session narrative.
- Keep the full narrative in `raw_memories.md` for Codex or in the dated memory file for Claude Code.
- No emoji.
- The opening brief is sacred - verbatim, untouched.
- The journey is non-negotiable - every session gets one.
- The middle is YOUR voice. You reflecting, not reporting.
- Use journal-style headers for scannability, not report categories. "What We Built and Why" = good. "Requirements Summary" = bad.
- Quote the user when their phrasing reveals something.
- Don't sanitize failures. Built and killed = important context.
- Claude Code full-entry file naming: `{YYYY-MM-DD}_{session-name}.md`.

## Gathering

1. **Host:** Determine whether the current runtime is Codex, Claude Code, or another host. If ambiguous, ask.
2. **Project path:** Use the current working directory as the project path unless the user supplied a different project root.
3. **Memory root:** Create the active host's memory directory if needed.
4. **Session transcript:** In Codex, use the current visible thread as the source of truth unless a stable local transcript path is available in the environment. If no transcript file is available, put this in the full entry header:
   ```
   **Conversation transcript:** `Codex current thread (transcript path unavailable)`
   ```
   In Claude Code, look under `~/.claude/projects/{project-slug}/` for the current session transcript if the host exposes one. Claude storage varies by version; if no readable transcript file is available, use the current visible thread and put this in the full entry header:
   ```
   **Conversation transcript:** `Claude Code current thread (transcript path unavailable)`
   ```
5. **Opening brief:** If a transcript file exists, read the first few lines. Parse structured transcript entries when available, find the first user message, extract the text, and copy it verbatim. If no transcript file exists, use the first user message visible in the current conversation and note that it came from visible context.
6. **Middle section:** Write from what you experienced in the conversation. You were there.
7. **Journey:** Reconstruct chronologically from the conversation flow.

## After

Tell the user which host you wrote memory for and the exact paths updated.

For Codex:

- `~/.codex/memories/MEMORY.md`
- `~/.codex/memories/raw_memories.md`

For Claude Code:

- `~/.claude/projects/{project-slug}/memory/MEMORY.md`
- `~/.claude/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md`
