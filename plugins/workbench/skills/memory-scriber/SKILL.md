---
name: memory-scriber
description: Capture a conversation's essence into the active host's memory directory. Supports Codex with a Workbench project-memory convention and Claude Code project memory without assuming the two plugin runtimes share state.
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

Codex does not currently expose Claude-style per-project memory directories as a native convention. Workbench adds that convention inside Codex's global memory root.

Global Codex memory root:

```text
~/.codex/memories/
```

Workbench project memory directory:

```text
~/.codex/memories/projects/{project-slug}/memory/
```

Derive `{project-slug}` from the absolute project path by replacing `/` with `-`.

Example:

```text
/Users/hamulia/dev/ai-usage-app
-> ~/.codex/memories/projects/-Users-hamulia-dev-ai-usage-app/memory/
```

Write:

1. `~/.codex/memories/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md` - full reflective session file.
2. `~/.codex/memories/projects/{project-slug}/memory/MEMORY.md` - concise project memory index.
3. `~/.codex/memories/MEMORY.md` - global router/index that points to project memory folders.
4. `~/.codex/memories/raw_memories.md` - append-only pointer log for dated project entries, not the full session narrative.

Create directories and files if needed.

Do not manually edit `~/.codex/memories/memory_summary.md` or `~/.codex/memories/rollout_summaries/`. Those are Codex-owned generated memory/consolidation artifacts.

### Claude Code output

Claude Code already uses project memory directories. Write into:

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

### Global Codex router entries

Codex only. Keep the global files compact and navigational.

In `~/.codex/memories/MEMORY.md`, ensure there is a section like:

```markdown
## Project Memories

Project-specific memories are stored under `~/.codex/memories/projects/`.

- `{project path}` -> `projects/{project-slug}/memory/`
```

When writing a new Codex project memory, add the project pointer if it is missing. Do not duplicate existing project pointers.

In `~/.codex/memories/raw_memories.md`, append a small pointer entry:

```markdown
### {YYYY-MM-DD} - {Session Title}

Project: `{project path}`
Memory: `~/.codex/memories/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md`
Host: `codex`

{1 sentence: what this session memory is about.}
```

Do not put the full reflective session in `raw_memories.md` by default. Full entries belong in the project directory.

### Project index entry

Append a compact entry near the top of the relevant project index:

- Codex: `~/.codex/memories/projects/{project-slug}/memory/MEMORY.md`
- Claude Code: `~/.claude/projects/{project-slug}/memory/MEMORY.md`

Use a `## Human-authored session memories` section. If that section does not exist, create it below any existing title/frontmatter and above generated index material.

Keep this entry short enough for future sessions to scan quickly:

```markdown
### {YYYY-MM-DD} - {Session Title}

Source: `{path to full entry}`
Project: `{project path}`
Host: `{codex | claude-code | other}`

{2-5 sentences: the durable thing future agents should remember. Capture working style, decisions, taste signals, product direction, constraints, and where the thread left off.}
```

### Full entry

For Codex, write this entry as:

```text
~/.codex/memories/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md
```

For Claude Code, write this entry as:

```text
~/.claude/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md
```

```markdown
---
session: {YYYY-MM-DD}-{session-title}
description: {One line - what happened and why it matters}
source: {codex | claude-code | other}
project: {project path}
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
- Codex uses a Workbench project-memory convention inside `~/.codex/memories/projects/{project-slug}/memory/`.
- Codex global `MEMORY.md` and `raw_memories.md` are routers/pointer indexes, not the place for full project memories.
- Claude Code uses `~/.claude/projects/{project-slug}/memory/`.
- Keep all `MEMORY.md` files compact. They are durable retrieval signals, not full session narratives.
- Keep the full narrative in the dated project memory file.
- No emoji.
- The opening brief is sacred - verbatim, untouched.
- The journey is non-negotiable - every session gets one.
- The middle is YOUR voice. You reflecting, not reporting.
- Use journal-style headers for scannability, not report categories. "What We Built and Why" = good. "Requirements Summary" = bad.
- Quote the user when their phrasing reveals something.
- Don't sanitize failures. Built and killed = important context.
- Full-entry file naming: `{YYYY-MM-DD}_{session-name}.md`.

## Gathering

1. **Host:** Determine whether the current runtime is Codex, Claude Code, or another host. If ambiguous, ask.
2. **Project path:** Use the current working directory as the project path unless the user supplied a different project root.
3. **Project slug:** Convert the absolute project path to a slug by replacing `/` with `-`.
4. **Memory root:** Create the active host's project memory directory if needed.
5. **Session transcript:** In Codex, use the current visible thread as the source of truth unless a stable local transcript path is available in the environment. If no transcript file is available, put this in the full entry header:
   ```
   **Conversation transcript:** `Codex current thread (transcript path unavailable)`
   ```
   In Claude Code, look under `~/.claude/projects/{project-slug}/` for the current session transcript if the host exposes one. Claude storage varies by version; if no readable transcript file is available, use the current visible thread and put this in the full entry header:
   ```
   **Conversation transcript:** `Claude Code current thread (transcript path unavailable)`
   ```
6. **Opening brief:** If a transcript file exists, read the first few lines. Parse structured transcript entries when available, find the first user message, extract the text, and copy it verbatim. If no transcript file exists, use the first user message visible in the current conversation and note that it came from visible context.
7. **Middle section:** Write from what you experienced in the conversation. You were there.
8. **Journey:** Reconstruct chronologically from the conversation flow.

## After

Tell the user which host you wrote memory for and the exact paths updated.

For Codex:

- `~/.codex/memories/MEMORY.md`
- `~/.codex/memories/raw_memories.md`
- `~/.codex/memories/projects/{project-slug}/memory/MEMORY.md`
- `~/.codex/memories/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md`

For Claude Code:

- `~/.claude/projects/{project-slug}/memory/MEMORY.md`
- `~/.claude/projects/{project-slug}/memory/{YYYY-MM-DD}_{session-title}.md`
