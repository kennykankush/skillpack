---
name: skill-advisor
description: Recommend which of the user's ALREADY-INSTALLED skills best fits a task or query. Use when the user asks "what skill should I use for X", "which of my skills fits this", "do I have a skill for Y", "what's at my disposal for Z", "recommend a skill from my toolkit", or when you need to pick the right skill from their available toolkit before starting work. This skill is read-only — it advises, it does not install. For installing new skills, use the separate skill-management workflow available in the current agent environment.
---

# Skill Advisor — Recommend from the User's Installed Toolkit

Your job is to help the user pick the right skill from what's **already installed**. You don't install anything. You don't do web research. You read their local skill index and match it to the task at hand.

This skill activates on queries like:
- "What skill do I have for X?"
- "Which of my skills should I use here?"
- "Recommend from my toolkit"
- "Do I have something for Y?"
- "What's at my disposal for Z?"

## How to answer

### Step 1 — Understand the task
Identify the domain and specifics. Examples:
- "build a landing page" → frontend design + motion + polish
- "make an iOS animation" → iOS + animation
- "review this component" → critique/audit flavor
- "set up a Neon database" → backend/data

### Step 2 — Read the index
Always start by reading `~/.agents/CATEGORIES.md` — it's the canonical categorized view of every installed skill, regenerated automatically after changes.

If `CATEGORIES.md` doesn't exist or is stale, fall back to reading the relevant local registries for the current agent environment:
- `~/.codex/plugins/cache/` (Codex plugin cache)
- `~/.agents/skills/` (shared local skills)
- `~/.agents/.skill-lock.json` (flat skills via npx skills)
- `~/.claude/plugins/installed_plugins.json` + plugin caches (plugin skills)
- `~/.claude/skills/` (standalone / skillfish-managed)

### Step 3 — Match skills to the task
Go through each relevant category in `CATEGORIES.md`. For each candidate skill, ask:
- Does its description trigger on THIS task?
- Is it a good fit or just tangentially related?
- How does it stack against similar skills in the same category?

### Step 4 — Rank and recommend
Give a ranked list (2-5 skills max — more is noise). For each:
- Full namespaced name (e.g., `impeccable:shape`, not just `shape`)
- One-line reason it fits
- When in the workflow to use it (pre-work, build, polish, review)

### Step 5 — Flag gaps
If the user's request reveals a category where their toolkit is THIN (e.g., they ask for Android UX and only have iOS skills), say so:

> "For Android specifically, you currently have `ui-design:mobile-android-design` but not much else. Consider asking `skill-manager` to discover more Android-focused skills."

This is how `skill-advisor` hands off to `skill-manager` naturally.

## Response format

Use this structure:

```
📚 For <task description>, from your installed toolkit:

🥇 **<full:skill-name>** — <one-line reason>
    <when to use: pre-work | during build | polish | review>

🥈 **<full:skill-name>** — <one-line reason>
    <when>

🥉 **<full:skill-name>** — <one-line reason>
    <when>

Optional: also consider **<name>** for <specific sub-aspect>.

Workflow suggestion:
  1. Start with X to plan/scaffold
  2. Use Y during build
  3. Apply Z before shipping

Gap: <if any category is thin, mention it here; suggest skill-manager>
```

Keep it tight. No preamble. No "I'll help you with that" fluff.

## What NOT to do

- **Don't install anything.** If the user needs a new skill, say "ask skill-manager to discover/install X."
- **Don't do web research.** Local data only.
- **Don't recommend project-scoped skills when the user is in a different project.** Respect scope.
- **Don't recommend skills the user doesn't have.** Only recommend from CATEGORIES.md.
- **Don't be verbose.** 3 ranked recommendations beat 10 loose mentions.

## User toolkit context (for grounding)

His skills live across three mechanisms:
- **Plugins** (namespaced like `plugin:skill`) — `impeccable:*`, `gsap-skills:*`, `ui-design:*`, `ui-ux-pro-max:*`, `frontend-design:*`, `codex:*`
- **Flat via npx skills** — things like `emil-design-eng`, `neon-postgres`, `hyperframes`, `text-to-speech`, `find-skills`
- **Skillfish / hand-authored** — `ios-design`, `motion-design`, `lottie-animator`, `memory-scriber`

Plus project-scoped skills in specific dirs (foundation-builder in jobber, element-quality in interfaces, chronicler + git-sync in fantopy-hadi). Don't recommend those outside their context.

## Example exchanges

**User:** "Which of my skills should I use for a landing page?"

**Response:**
```
📚 For a landing page, from your installed toolkit:

🥇 **impeccable:shape** — plan the UX/UI before coding (discovery interview → design brief)
    When: before you write any code

🥈 **ui-design:visual-design-foundations** — type, color, spacing fundamentals
    When: during initial design decisions

🥉 **frontend-design:frontend-design** — distinctive production-grade interface implementation
    When: during build

Also consider: **impeccable:bolder** if the page feels safe/boring, and **impeccable:polish** before shipping.

Workflow suggestion:
  1. impeccable:shape to plan
  2. ui-design:visual-design-foundations + frontend-design:frontend-design during build
  3. impeccable:polish before ship

Gap: none for this task — you're well-covered.
```

**User:** "what do I have for Android?"

**Response:**
```
📚 For Android UX specifically:

🥇 **ui-design:mobile-android-design** — Material Design patterns for Android

That's it for Android-specific skills in your toolkit. You have strong iOS coverage
(ios-design, ui-design:mobile-ios-design) and cross-platform (ui-design:react-native-design),
but Android alone is thin.

Gap: If you want more Android depth, ask skill-manager to discover Android-focused skills.
```
