---
name: frame-qa
description: Review generated storyboard frames or contact sheets for product-launch motion quality. Use when the user asks whether frames look professional, cohesive, AI-video-ready, faithful to screenshots, or should be regenerated. Outputs keep/regenerate decisions and targeted regeneration notes; does not manually edit frames.
---

# Frame QA - Storyboard Quality Gate

This skill reviews storyboard frames after generation.

It acts like a motion-design art director and production QA pass: keep what works, reject what damages product truth, and write precise regeneration direction.

## Activation

Use this skill for requests like:

- "go through all the frames"
- "make sure these look professional"
- "vet against what we built"
- "which frames should regenerate?"
- "this looks amateurish"
- "does this honor the screenshots?"
- "is this good for Higgsfield / Omni?"

Do not use this skill to generate new frames unless the user explicitly asks for regeneration and `videos:storyboard` + `imagegen` are also used.

## Inputs

Inspect as available:

- individual generated frames
- contact sheet
- prompt logs
- source product screenshots
- accepted prior versions
- rejected examples
- style contract
- narrative beat list
- target video tool constraints

Use visual inspection for image files. Do not judge from filenames alone.

## Review Axes

Score each frame against:

1. Product truth: real UI language, real brand, correct feature premise.
2. Cohesion: belongs to the same sequence as the other frames.
3. Motion plausibility: looks like a still from an actual launch animation.
4. Composition: hierarchy, spacing, crop, negative space.
5. Text quality: no gibberish, fake paragraphs, bad labels, or overcrowding.
6. Logo/brand fidelity: no invented marks or mutated brand assets.
7. AI-video readiness: stable enough for interpolation without hallucinated resets.
8. Professional finish: not amateur, not generic, not overly decorative.

## Decision Labels

Use only these labels:

- `keep`: frame is production-usable
- `keep with note`: usable, but needs a handoff constraint
- `regenerate`: violates product truth or quality
- `optional`: nice but not needed for the sequence
- `replace narrative`: the frame is okay visually but the beat is wrong

## Output Format

Default:

```text
Frame QA

Overall:
<short read on the sequence>

Frame 01 - keep
Why:
Motion note:

Frame 02 - regenerate
Issue:
Regeneration direction:

Frame 03 - keep with note
Why:
Handoff constraint:
```

For many frames, use a compact table:

```text
| Frame | Decision | Issue | Regeneration / Handoff Note |
| --- | --- | --- | --- |
```

## Regeneration Direction

Good regeneration direction names the exact failure and the desired fix:

```text
Regenerate frame 06 with upright UI, one centered leaderboard module, cleaner gradient background, no extra decorative cards, no generated paragraphs, and stronger continuity with frames 05 and 07.
```

Bad:

```text
Make it better and more professional.
```

## AI-Video Readiness Checks

Flag frames that may look good as stills but fail in video:

- too much angled UI
- dense text that will mutate
- end frame radically different from start frame
- important logo too small
- background with many decorative elements
- multiple UI modules competing
- lack of clean hold frame for stitching

Recommend either a simpler frame or a clearer motion-handoff constraint.

## What Not To Do

- Do not manually edit frames.
- Do not create local composites to "fix" bad generations.
- Do not accept mutated logos or gibberish because the overall vibe is nice.
- Do not regenerate everything if only one or two frames break cohesion.
- Do not make the QA so broad that the user cannot act on it.
