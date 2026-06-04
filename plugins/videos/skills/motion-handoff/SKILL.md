---
name: motion-handoff
description: Create AI-video motion handoff prompts and keyframe grouping plans from accepted storyboard frames. Use when the user has storyboard images and needs Higgsfield Canvas, Gemini/Omni, Runway, Krea, or another video model to understand frame order, motion intent, clip stitching, and UI stability constraints. Does not generate storyboard frames; pair with videos:storyboard only when new frames are still needed.
---

# Motion Handoff - AI Video Keyframe Director

This skill turns accepted storyboard frames into motion-ready instructions for AI video tools.

It is not a storyboard generator. It assumes the visual direction is mostly approved and focuses on helping a video model interpret the frames as a sequence instead of hallucinating unrelated product footage.

## Activation

Use this skill for requests like:

- "give me the Higgsfield prompt for these frames"
- "how do I connect these storyboard images in Canvas?"
- "make frame 1 to 3 animate as one clip"
- "split these into AI video batches"
- "write stitch-safe motion prompts"
- "the video model is pasting the UI instead of animating it"

Do not use this skill for first-pass narrative planning, visual style exploration, frame QA, or image generation unless the user explicitly asks for those parts too.

## Preflight

Before writing handoff prompts, establish or state assumptions for:

- target tool: Higgsfield Canvas, Gemini/Omni, Runway, Krea, Kling, Seedance, manual editor, or unknown
- input shape: one image, start/end images, multi-keyframe node, or connected image nodes
- clip duration and aspect ratio
- accepted source frames and their order
- whether the frames are keyframes, style references, or only visual inspiration
- whether the clip must animate in, animate out, or loop
- stitch strategy: overlap boundary frame, clean hard cut, crossfade, or end-card hold
- stability constraints: exact UI text, logo fidelity, upright UI, no camera drift, no extra screens
- what should change over time: position, scale, opacity, typing, glow, card entrance, chat bubbles, buttons, counters
- what must stay locked: brand mark, product UI layout, readable labels, crop, background palette

If the order or target workflow is unclear, ask one concise question before writing the final prompt.

## Core Rule

When multiple images are connected to a video generation node, explicitly define them as the timeline.

Use wording like:

```text
Treat the connected images as sequential keyframes in this exact order, not as separate style references. Image 1 is the opening state, image 2 is the motion midpoint, and image 3 is the final state.
```

Never assume the tool will infer order correctly from upload order alone.

## Output Formats

Choose the smallest useful output:

- a single paste-ready prompt
- a node workflow
- per-shot prompt files
- a batch manifest
- a short handoff note with model settings and risks

For node workflows, use a concrete shape:

```text
Image Nodes [01, 02, 03] -> Video Generation Node
Model: <model>
Duration: <seconds>
Aspect: 9:16
Prompt: <paste-ready prompt>
```

## Prompt Anatomy

A good handoff prompt has six parts:

1. Intent: name the clip's job in the launch video.
2. Keyframe order: define each image as a stage of the timeline.
3. Motion: describe only the transitions the model should create.
4. Product constraints: preserve UI, text, logos, and layout.
5. Style constraints: product-launch motion design, clean gradients, glass, spacing, typography.
6. Negative constraints: no new screens, no realistic footage, no random text, no invented logos.

Example:

```text
Create a polished SaaS product-launch motion-design clip using the connected images as sequential keyframes in this exact order, not as separate style references.

Image 1 is the quiet opening state, Image 2 is the midpoint where the UI modules ease in and glow, and Image 3 is the final resolved product state. Animate with clean 2D/2.5D motion: soft ease-in, slight scale, opacity reveal, subtle teal glow, and controlled parallax in the background only.

Preserve the product UI structure, logo, readable labels, button shapes, and 9:16 composition. Do not add new screens, fake dashboards, random paragraphs, realistic football footage, or invented brand marks. The result should feel like a premium SaaS launch motion graphic, not a phone recording or cinematic sports ad.
```

## Stitch-Safe Sentences

Add stitch guidance only when the clip will be joined to neighboring clips.

Opening clip:

```text
Begin from a near-empty clean stage for the first few frames so the previous clip can cut into it smoothly.
```

Middle clip:

```text
Start by matching Image 1 exactly for a brief hold, then move through the sequence and end by holding Image <last> cleanly for stitching.
```

Final clip:

```text
End with a calm resolved hold on the final brand/product frame; avoid extra flourish after the last keyframe.
```

## UI Stability Guidance

AI video tools often fail when UI is too angled, too dense, or text-heavy.

Prefer:

- upright or nearly upright UI plates
- one primary module per shot
- large readable labels
- stable crops with minimal camera travel
- controlled opacity/scale reveals
- textless or minimal-text plates when copy can be added later

Avoid:

- asking the model to invent typing-heavy UI
- rapidly transforming a full dashboard
- angled UI that must resolve into exact upright UI
- start/mid/end frames with different layout systems
- prompts that say "make it dynamic" without naming the exact motion

## Failure Diagnosis

If the model output looks wrong, classify the failure before reprompting:

- `sequence confusion`: it treated images as references, not ordered keyframes
- `paste failure`: it pasted a UI image onto the background instead of integrating motion
- `text drift`: readable labels mutated or became gibberish
- `camera drift`: the clip became cinematic footage instead of product motion
- `over-animation`: too much 3D, rotation, particles, or realism
- `under-animation`: static image with only late element spawns

Then write a narrower prompt that fixes that exact failure.

## What Not To Do

- Do not generate new storyboard frames.
- Do not manually edit images.
- Do not create fake intermediate frames unless the user asks for more storyboard generation.
- Do not overfit a prompt to a fixed frame number like "1 to 3" unless those are the actual selected frames.
- Do not assume Higgsfield, Gemini, or any other tool is the target if the user has not said so.
