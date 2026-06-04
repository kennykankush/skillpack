---
name: style-contract
description: Distill screenshots, brand assets, and motion references into a reusable visual style contract for storyboard or launch-video generation. Use when the user is sensitive about taste, cohesion, product-launch motion-graphic vibe, reference borrowing, logo fidelity, UI realism, or avoiding generic AI visuals.
---

# Style Contract - Visual Taste Guardrail

This skill creates a written contract for how a storyboard or launch-video system should look and feel.

It is used before generation or regeneration so the agent does not chase one frame at a time and lose cohesion.

## Activation

Use this skill for requests like:

- "get the vibe right"
- "this looks amateurish"
- "take inspiration from these references"
- "do not copy this verbatim"
- "make it more product launch SaaS motion graphic"
- "the UI is nice but the generated text kills it"
- "background should be cleaner / more gradient / less graphic"

Do not use this skill for file batching, video prompting, or frame QA unless paired with those skills.

## Inputs To Study

Inspect only the relevant materials:

- product screenshots
- accepted storyboard frames
- rejected storyboard frames
- brand kit and logo assets
- reference images or videos
- written taste notes from the user
- target video model limitations

Summarize what the product itself already does well before adding external style.

## Contract Sections

Write the contract in these sections.

### Product Visual Truth

Capture what must stay faithful:

- actual UI components
- real logo and mark
- button shapes
- border radius
- color palette
- gradients and glows
- type weight and scale
- density and spacing
- any distinctive product modules

### Borrow From References

Name transferable traits only:

- pacing
- spaciousness
- gradient handling
- glass depth
- type hierarchy
- negative space
- camera restraint
- clean reveal behavior
- module choreography

### Do Not Borrow

Name what must not be copied:

- reference brand names
- reference product concepts
- unrelated UI controls
- fake icons
- text strings
- layouts that do not fit the user's product
- 3D/realistic footage if the desired style is product motion

### Composition Rules

Define recurring structure:

- full-bleed stage or clean gradient background
- one primary UI element per frame when possible
- copy can sit separate from UI
- no nested cards unless product UI actually has them
- use crop, scale, and edge placement for motion implication
- preserve breathing room

### Text Policy

Set a strict text mode:

- `no generated text`
- `minimal exact text`
- `real UI text only`
- `copy added later in editor`

For AI image generation, prefer fewer words. For AI video, treat important text as risky unless it is already baked into a stable frame.

### Motion Feel

Describe the implied motion:

- smooth ease-in/out
- controlled scale
- opacity reveals
- soft glow pulses
- subtle parallax
- card/module slide
- chat bubble stagger
- final hold

Avoid vague terms like "dynamic" unless paired with exact motion mechanics.

### Avoid List

Build a project-specific avoid list from user feedback:

- amateur collage
- random background graphics
- fake dashboard labels
- placeholder bars
- mutated logos
- gibberish text
- unrealistic stadium/crowd footage when product UI should lead
- over-rotated UI if the video model cannot resolve it
- generic centered SaaS cards

## Output Format

Default:

```text
Style Contract: <project / sequence name>

Product Visual Truth:
- ...

Borrow:
- ...

Do Not Borrow:
- ...

Composition:
- ...

Text:
- ...

Motion:
- ...

Avoid:
- ...
```

If the user is about to generate frames, end with a compact generation directive that can be reused across prompts.

## Regeneration Use

When a frame fails, do not rewrite the whole style. Identify which contract rule it violated:

- too graphic
- too literal UI screenshot
- not enough product truth
- copied reference
- fake/mutated logo
- text pollution
- bad density
- video-model unstable angle

Then produce a narrower regeneration prompt.

## What Not To Do

- Do not generate images.
- Do not manually edit images.
- Do not turn every reference into mandatory rules.
- Do not copy reference compositions verbatim.
- Do not let a single nice frame overwrite the contract for the whole sequence.
