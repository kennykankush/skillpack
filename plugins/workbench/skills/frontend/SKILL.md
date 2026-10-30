---
name: frontend
description: Agentic frontend design framework, with a code path and a Claude Design path. Use for any UI work where how it looks matters - new pages and apps, revamps, redesigns, polishing, or when the user says it looks generic, amateurish, plain, cheap or "not it", asks for a style ("premium", "modern", "clean", "sleek", "like Stripe"), or asks to research how good products do something. Checks its tooling first, studies what the product is and who uses it, then runs taste, references, style options, design system and tokens, asset fetching, build with real content and every state, self-critique and memory, with motion as the final layer. Keeps a taste memory that learns from every approval and rejection.
---

# frontend

A framework, not a style. There is an infrastructure of reference sources, design skills, motion skills and design packages, and asset sources. Use what the task needs and skip the rest. The non-negotiables are the gates: see real references before deciding, write the system before building, critique your own screenshots before showing anything, and record what the user says.

The user should never have to be the visual QA, never have to ask for references to be looked at, and never have to ask for the design skills to be loaded.

## 0. Check the setup

Once per session, run:

```
python3 <skill-dir>/scripts/check.py
```

It reports every reference MCP, skill, the brand-systems library and the taste memory across Claude Code, Codex and Gemini, as OK / AUTH / MISSING / OFF / UPDATE, with the fix command for each. It never installs anything.

- Everything OK: say so in one line and continue.
- Anything else: show the user the short list with the fix commands and offer to run them. Logins (AUTH) are theirs to do; say exactly where (for example `/mcp` in Claude Code). Paid sources (Refero, Mobbin) are optional: mention once that they exist, never push.
- If the user declines, continue with what is available. Only a missing browser tool (`chrome-devtools`) or missing `impeccable` blocks the full loop; without them, say what is degraded and proceed.
- **Config is not the same as loaded.** The script reads config files; a session only has the MCP servers that existed when it started. Confirm the reference tools are actually callable in this session (tool names like `mcp__refero__*`, `mcp__mobbin__*`, `mcp__awwwards__*`, `mcp__madegood__*`, `mcp__lazyweb__*`; load deferred tools through the host's tool search). If a configured source is not loaded, tell the user it needs a fresh session (or `/mcp` reconnect) to appear, and list which sources this session can use.
- **Logged in is not the same as paid.** Refero and Mobbin accept the login but refuse searches without an active plan. Make one cheap real search on each paid source during setup; if it refuses, report it here ("Refero: plan inactive") rather than discovering it mid-research.
- Taste memory missing: copy `TASTE.template.md` to `~/.agents/taste/TASTE.md` (with the user's agreement) so learning can start.

## Infrastructure

**See (real screens, by domain)** - query every one that is loaded (see step 2), not just the first that answers:
- `refero` - styles (type, colour, layout, spacing), screens, flows. Best for why something looks good. Paid; ration calls.
- `mobbin` - large library of app and web screens, flows, sections. Paid.
- `lazyweb` - screens, flows, A/B experiments, growth patterns.
- `awwwards` - award-winning sites; captures live sites, motion DNA, scroll maps, side-by-side comparisons.
- `madegood` - typography and brand references, palettes, UI screens.
- `~/.agents/references/awesome-design-md/design-md/<brand>/DESIGN.md` - ready-made brand systems (Stripe, Linear, Vercel, Cursor, Framer, Coinbase and more). Free and offline; the fastest way to blend known styles.
- Galleries reachable through the browser: Godly, Land-book, Lapa Ninja, SiteInspire, Kombai Gallery, Dribbble (often unshipped concepts; treat as mood, not proof).

**Measure and capture** - `playwright` for screenshots at several viewports and clicking through flows; `chrome-devtools`: open a reference live, screenshot it, read computed fonts, sizes, line heights, colours, radii, shadows and spacing (`evaluate_script`, `get_css_styles`). Computer use is the fallback for sites that block headless browsers.

**Decide and build** - `impeccable` is the spine (PRODUCT.md, DESIGN.md, shape, typeset, layout, colorize, bolder, quieter, polish, critique, finish review). `ui-ux-pro-max` for its searchable data (styles, palettes by industry, font pairings, UX rules) when proposing directions; `refero-design` for the Refero research method; `better-icons` to find real icons instead of drawing them; `emil-design-eng` for component feel; `design-taste-frontend`, `high-end-visual-design`, `frontend-design` as extra style lenses when useful.

**Typography** - [typography.md](typography.md): finding faces from references, free and paid sources, pairing, setting (scale, trim, wrapping, numerals) and loading without layout shift.

**Look development** - [lookdev.md](lookdev.md): lighting, materials, texture, depth and compositing, colour grading, lens and post, and the rule for effects. Shaders, textures and effects serve one look.

**Assets and graphics** - [assets.md](assets.md): icons, photography, illustration, 3D, motion files, backgrounds, product imagery, logos. Material is fetched, never faked.

**Packages** - [libraries.md](libraries.md): shaders, 3D, interactive vector, motion, unstyled primitives, type, icons, charts. Installed per project; fetch current docs with `context7`.

**Motion** - `motion-director` (concept and stack), `motion-design` / `motion-design-lottie` (timing, easing, choreography), `gsap-*`, then `web-motion-auditor`, `design-motion-principles`, `fixing-motion-performance` to check it.

**Verify** - impeccable `critique` and its finish reviewer, `web-design-guidelines`, `webapp-testing`.

If a source fails mid-task, say so in one line and use the others. Never replace the reference step with text-only web search.

## Load the skills, do not just know them

The infrastructure only helps once loaded. At each step, actually invoke the skills it names through the host's skill mechanism (the Skill tool in Claude Code, `$skill` in Codex) and read the reference files; knowing a skill exists is not using it. Load them when the step starts, not after the user asks.

| Step | Load |
|---|---|
| 1b product | `impeccable` (run its `context`; `init` if PRODUCT.md is missing) |
| 2 references | `refero-design` (when Refero is active), `lazyweb` search skills; `dataviz` for dashboards and analytics; `ui-ux-pro-max` for palette, type and style data |
| 3 styles | `ui-ux-pro-max`; one of `design-taste-frontend`, `high-end-visual-design`, `frontend-design` as a style lens when useful |
| 4 system | `impeccable` (`shape`, `typeset`, `colorize`, `layout` as needed); read typography.md and lookdev.md |
| 4b material | `better-icons`; read assets.md |
| 5 build | `impeccable`, `emil-design-eng`; `harden` / `onboard` for states; read libraries.md |
| 6 critique | `impeccable` (`critique`, `polish`, the finish reviewer); `web-design-guidelines`; `webapp-testing` for multi-viewport capture |
| 7 motion | `motion-director`, then `motion-design` or `motion-design-lottie`, `gsap-*` if GSAP is in use; `web-motion-auditor` and `fixing-motion-performance` to check |

Skip a skill only when the step genuinely does not need it, and say which skills were loaded in the step's report.

## Two paths

- **Code path (default)** - design and build directly in the project's code. Works in every agent.
- **Claude Design path** - when the user says "use Claude Design", wants to see designs before code, or wants comps to share and comment on. Claude Design lives on the web (claude.ai/design): designs and prototypes sit on a canvas there, not in the repo. Available only in Claude Code; in Codex or Gemini, say so and use the code path.

On the Claude Design path, the loop is the same, with these changes:
- Steps 1-2 run as normal; the references still drive everything.
- Step 3: create the 2-3 directions as Design artifacts (Artifact tool, quickstart intent `design`, which also lists the user's design systems on claude.ai). Share the links; the user compares and comments on the canvas.
- Step 4: if a design system exists on claude.ai, build on it; otherwise make one from the system written in DESIGN.md.
- Iterate on the canvas until a direction is approved, logging feedback as in step 8.
- Then build the approved design in code (steps 5-7), using the artifact as the comp the self-critique compares against.
- Afterwards, offer `/design-sync` to keep the project's component library and the claude.ai design system in step, so future designs and decks use the same system.

## The loop

### 1. Read taste
Read `~/.agents/taste/TASTE.md`, then the project's PRODUCT.md, DESIGN.md and `.design/` if present. Translate the user's style words through TASTE.md; where TASTE.md is silent, state your reading of the word as concrete visual traits. Either way, say the translation in one line so the user can correct it.

Classify the request:
- **new** - a surface that does not exist yet
- **revamp** - replace the visual world ("redo", "start over", "not it", "go all out")
- **refine** - keep the world, raise quality ("spacing is off", "fonts feel weak")
- **blend** - "like X but Y", "X meets Y"
- **critique** - review only, no edits

**Calibrate when the words are vague.** On a new project, or when the style words are ambiguous and TASTE.md does not settle them, run a quick visual intake before research goes deep: show 6-9 varied reference screens from the domain and ask which feel right and which feel wrong. One round of pointing replaces several rounds of adjectives. Record the answers in TASTE.md (with the screens) and the log.

### 1b. Understand the product (gate: no references without this)
Design follows what the product is for. Before looking at anyone else's screens, study this one:

- **Read it**: PRODUCT.md, README, docs, the routes and page components, the data models and API shapes. If the app runs, open it and click through every screen and the main flow end to end, screenshotting as you go.
- **Write down** (in PRODUCT.md, creating it through impeccable `init` if missing, or confirming it if present):
  - what the product does and the category it competes in
  - who uses it (role, expertise, how often, in what setting: a SOC analyst at a desk all day reads differently from a founder checking once a week)
  - the core jobs, in order of importance, and the one flow that matters most
  - the information architecture: screens, navigation, how they connect
  - the key objects and data (findings, assessments, invoices, tracks...) and their states
  - the mode of each surface: persuade, operate, read or experience (impeccable's terms)
  - what is working today and must survive the redesign
- **Then derive** the domain to research, the surfaces in scope, and their element types (step 2), from this, not from the request's wording alone.

Say the product read back to the user in three or four lines so a wrong reading is caught before research starts. On a refine of a product already studied this session, a quick confirmation is enough.

### 2. See references (gate: no direction without this)
From the product study, name the domain (fintech, security, dev tool, SaaS marketing, consumer app...) and the surfaces (dashboard, settings, login, onboarding, setup...). Gather two groups of references, labelled, and both are required:

- **Domain references** - products in the same category. They answer what this screen must show and how people in this field expect it to behave: the data, the vocabulary, the workflows, the density. A security tool learns findings, severity and evidence from security tools.
- **Quality references** - the best-crafted products from any category. They set the visual bar: type, spacing, depth, surfaces, motion.

Structure comes from the domain group; craft comes from the quality group. Never present a quality reference as the domain's gold standard. When a source is thin on the domain (Refero has few security products, for example), say so and look harder elsewhere: Lazyweb, Mobbin, product documentation screenshots, public demos, the products' own marketing pages showing the real UI.

**Research the parts the surface is made of, not just the page.** Without being asked, break the surface into its element types and gather references for each:

| Surface | Element types to research |
|---|---|
| dashboard / analytics | KPI tiles, sparklines, trend and area charts, stacked and inline bars, donuts and gauges (sparingly), heatmaps and coverage grids, progress meters, tables with in-cell bars, legends, filters and date pickers, tooltips, empty and loading states. Load the `dataviz` skill for chart form and colour |
| settings / admin | row anatomy (label, help, control), grouping and section headings, danger zones, save patterns |
| onboarding / setup | step structure, progress, defaults, review step, first-run and empty states |
| auth | single-column form, providers, error and recovery states, the brand moment |
| marketing / landing | hero, proof, feature sections, pricing, footer, the signature visual |
| detail / report | header summary, evidence blocks, timelines, export and share |

Fan out across **every loaded source**, in parallel where the host allows. Each source sees something the others do not:

| Source | Ask it for |
|---|---|
| `refero` | styles for the domain (type, colour, spacing systems), plus screens for the surface |
| `mobbin` | screens and flows for the surface and its competitors |
| `lazyweb` | screens, flows, and experiments if the surface converts (signup, pricing, onboarding) |
| `awwwards` | sites at the quality bar; motion and scroll treatment |
| `madegood` | typography and brand references |
| brand `DESIGN.md` files | 2-4 brands in or near the domain, as complete systems |
| user-provided screenshots and their own past work | the stated taste, weighted highest |
| live sites (`chrome-devtools` / `playwright`) | product pages, docs and public demos of domain products; measured tokens of the quality references |

The brand DESIGN.md files and live capture are free and always available: run them every time, as the baseline that holds even when paid sources refuse or come back thin. Read any reference you saved before writing about it; never cite a screen you have not looked at.

Coverage floor: 15-30 screens from at least 3 different sources (4+ when they are loaded), with at least 5 domain references and at least 5 quality references. One source is never enough, however good its results; stopping at the first answer is the most common way this step fails. Then open the best 3-5 live (`chrome-devtools` / `playwright`) and measure their real tokens: fonts, sizes, radii, spacing, shadows, background treatment. For refine, the floor is 8-10 references for the specific element, from at least 2 sources.

When the user asks to "check references", "find the golden standard" or similar, rerun the fan-out for the element in question; do not answer from the earlier set alone.

Write `.design/REFERENCES.md` in the project:
- a coverage line: how many references came from each source, how many are domain and how many quality, and any source that was unavailable and why
- each reference: link, screenshot (saved under `.design/refs/`), the source it came from, its group (domain or quality), one line on what it does well
- measured tokens from the live references
- the shared patterns: type pairing and scale, spacing rhythm, palette logic, background and depth, card language, motion character

If the floor cannot be met (sources not loaded, quotas spent), say so plainly before proposing directions, rather than presenting thin evidence as research.

When a later round of research contradicts an earlier one (corner sizes, palette, density), do not silently switch: name what changed, which evidence supersedes which, and update REFERENCES.md and DESIGN.md so they agree.

### 3. Offer styles (be proactive)
**Show, do not describe.** Before asking the user to choose anything, show them the key reference images next to a screenshot of the current state. A direction the user has only read about is not approved.

In a terminal host the user cannot see images in the chat, so build a contact sheet: write `.design/refs/index.html`, a simple grid of the saved screenshots, each captioned with name, source, group (domain or quality) and the one thing it teaches, with the current state's screenshot first; then open it for the user (`open` on macOS, `xdg-open` on Linux) and say it is open. Do the same for comps (`.design/comps/index.html`). In hosts that render images inline, show them directly.

Do not wait to be told a style. From the references, propose 2-3 named directions that fit the domain, each in a few lines: mood, type, palette, depth, signature detail, and the reference it comes from. Example shapes: "quiet precision" (Linear-like), "glossy fintech" (rich gradients, big numbers), "editorial" (large serif type, generous space), "technical" (mono accents, grids). Recommend one.

- revamp / new: show each direction as a quick comp of one representative screen (rendered and screenshotted, or a Claude Design artifact), and let the user pick before the full build. Build the comps in parallel where the host allows (one sub-agent or fork per direction, each given the references and one direction brief), so they come back faster and stay genuinely distinct.
- refine: skip new directions unless the references show the incumbent style itself is the problem; then say so. Show a before and after of the element in question before applying it everywhere.
- After each round of feedback, offer the next useful variation ("bolder", "quieter", a blend of two directions) rather than only asking what to change.

### 4. Write the system (gate: no code without this)
Record in DESIGN.md (impeccable `init` / `shape` own the file):
- fonts (named, with the reason seen in references), type scale, weights, set per typography.md
- look development: light direction, materials per surface, texture, elevation system, colour grade, and at most one signature effect (lookdev.md)
- spacing grid, container widths, alignment rules
- palette and roles, gradients, surfaces and depth (shadow, highlight edge, blur)
- radius, card and button language: one language reused everywhere
- packages chosen from libraries.md, and why
- asset language: one icon set, one illustration or photo treatment, the background and texture approach (assets.md)
- light and dark (if the product has both), and breakpoints

Change the system at its source: edit the token values and the components that own a style. Do not append override layers (`!important` blocks, selector lists that restyle many components from outside) on top of the old system; they hide the real values, fight each other on the next change, and make drift certain.

Then write the tokens as code the build must use: CSS custom properties, or the project's theme file (Tailwind theme, token JSON) if it has one. Components reference tokens, never raw hex values or one-off pixel numbers. With impeccable's detector hook on, raw values get flagged as they are written.

### 4b. Fetch material
Before building, gather the real assets the system calls for (assets.md): icons through `better-icons`, photography graded to the palette, illustration or generated art in one style, product screenshots in a consistent frame, 3D or Lottie files if the direction uses them. Record each with its source and licence in `.design/ASSETS.md`. No lorem pictures, stock blobs or hand-drawn icons in anything shown to the user.

### 5. Build
Build with impeccable and the craft skills loaded from the start. When one element looks off, check whether the type scale, spacing rhythm or card language is the cause and fix it everywhere, not just there. Build static first; motion comes last.

Build with realistic content: real or realistic copy, long names and numbers, busy and sparse data. Build every state the surface has: empty, loading (skeletons that match the final layout), error, partial, first-run. impeccable `harden` and `onboard` cover these.

### 6. Self-critique (gate: nothing is shown before this)
Passing tests and a commit are not this step. Before telling the user to reload or look, you must have screenshotted the result yourself (Playwright or chrome-devtools) at desktop and mobile, in every theme the product has, and looked at the images. Set them beside the top references (add them to the contact sheet). Check:
- edges align to one grid; nothing overflows or scrolls sideways
- spacing follows the rhythm; no cramped or floating groups
- type hierarchy is clear and the chosen fonts actually render
- one card and button language; no mixed styles on one page
- empty, loading, error and first-run states exist and look designed; loading does not shift layout
- realistic and long content does not break the layout
- dark mode (if present) and every breakpoint hold up, not just desktop and one phone width
- assets are real and share one language; icons come from one set
- tokens are used; no stray raw values
- contrast and focus states pass a quick accessibility check; nothing obviously heavy (huge images, blocking fonts)
- nothing on the TASTE.md Rejected list or in the project's rejections has crept in (re-read the list against the screenshots; for example coloured outlines on cards)
- it reads at the references' level, not as a template

Use impeccable critique or the finish reviewer for anything substantial. Treat impeccable's detector hook findings as part of this step: when it flags a pattern (a side-stripe accent, say), fix that pattern everywhere it occurs, not only the flagged line, and do not ask the user whether to keep the other instances. The launcher lives at `<impeccable-skill-dir>/scripts/impeccable` (for example `~/.claude/skills/impeccable/scripts/impeccable hooks ignore-value ...`); call it there rather than through npx.

Fix everything you found in one batch, re-check once, then show. Do not hand the user a result with weaknesses you already saw and listed as "next"; fix them first, unless they need a decision only the user can make. Show screenshots, not descriptions.

**Make feedback precise.** When showing work, offer the sharpest feedback tool available: impeccable `live` (the user clicks an element in the browser and gets variants of it), comments on a Claude Design artifact, or numbered annotations on the screenshots so the user can say "3 is off" instead of describing it.

### 7. Motion (the final layer)
Once the static design is approved, add motion: `motion-director` for the concept and stack, the timing skills for feel, the right package from libraries.md. Motion should confirm the hierarchy already there, not rescue a weak layout. Check with `web-motion-auditor` (including reduced motion) before showing it.

### 8. Remember
After each user reaction, before moving on:
- Append to `~/.agents/taste/log.md`: date, project, surface, what was shown, the user's words verbatim, verdict (approved / rejected / partial), one-line lesson.
- Project-specific decisions go to the project's DESIGN.md.
- When a lesson repeats in 2 or more projects, or the user states it as a general preference, promote it into TASTE.md (decoded words, Approved, Rejected, Working rules).
- If feedback contradicts a TASTE.md rule, do not overwrite silently: name the conflict and ask which holds.

A rejection of the direction changes the direction; do not polish the rejected one.

## Pace

Stop only at the real decision points: choosing a direction, a change the user did not ask for that alters scope or identity, and anything only the user can do (a login, a purchase). Everywhere else, keep going.

- When the user says "go ahead", "do everything", "keep going" or similar, run the whole remaining plan in one go: every screen and every fix you listed, each through build and self-critique, then report once at the end with screenshots. Do not end a turn with "shall I carry on?" or "next I would..." when the next step is already agreed.
- Within a turn, finish what you listed; do not stop after the first item to ask about the second.
- A long conversation is a reason to write the state down (status file, DESIGN.md, REFERENCES.md) so work survives, not a reason to stop. Suggest a fresh session at most once, and keep working if the user says to build here.

## Budget

Refero and Mobbin calls are metered. Search broadly with the free sources and the brand DESIGN.md files first; spend paid calls on the specific screens and styles that matter. Reuse `.design/REFERENCES.md` across iterations instead of re-searching.

## Output
Short: the one-line taste reading, references used (links), directions offered and the one chosen, screenshots, and what was written to memory.
