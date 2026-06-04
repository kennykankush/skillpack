---
name: batch-prep
description: Prepare accepted storyboard frames for AI-video upload batches. Use when the user needs Omni/Gemini 10-image folders, Higgsfield 9-image groups, sequential copies, overlap frames, manifests, contact sheets, or prompt placeholders. File workflow only; does not creatively edit or generate frames.
---

# Batch Prep - AI Video Upload Organizer

This skill turns accepted frames into clean upload-ready folders for video tools.

It handles naming, copying, grouping, overlap, manifests, and prompt-file scaffolding. It does not change the creative content of the images.

## Activation

Use this skill for requests like:

- "split these for Omni"
- "Higgsfield can take 9 photos"
- "make two folders for batches"
- "copy the pictures into omni and higgy"
- "name them sequentially"
- "make 5 second batch pictures"
- "create upload-ready folders"

Do not use this skill for deciding the narrative, generating new frames, or writing detailed motion prompts unless paired with the relevant skill.

## Preflight

Establish:

- source frame folder
- accepted frame list or whether to use all frames
- target tool and max image count
- batch duration target
- whether boundary overlap is needed
- naming convention
- destination root
- whether prompt files and manifests are needed

If the source folder is ambiguous, inspect likely folders and ask only if there are multiple plausible accepted sets.

## File Rules

Allowed:

- create folders
- copy files
- rename copies sequentially
- create manifests
- create contact sheets from accepted frames
- create empty or draft prompt files

Not allowed:

- alter pixels
- patch logos/text
- manually composite UI
- run creative image generation
- delete source frames

## Batching Strategy

Default strategies:

- Gemini/Omni: group up to 10 images per chat or upload set.
- Higgsfield: group up to 9 images per Canvas/image group unless the user says otherwise.
- Start/end image tools: create two-frame or three-frame shot folders.
- Manual editor: group by narrative beat rather than hard image limit.

For stitched clips, prefer one repeated boundary frame when the tool benefits from continuity:

```text
batch-01: 01 02 03 04 05
batch-02: 05 06 07 08 09
```

Do not use overlap if the user wants hard cuts or if the model keeps repeating the boundary frame badly.

## Naming

Use stable, readable names:

```text
01-hook.png
02-agent-reveal.png
03-chat.png
```

For tool folders:

```text
omni/batch-01/01-hook.png
higgsfield/batch-01/01-hook.png
```

Do not rename source files in place. Rename the copies.

## Manifest

Create a `manifest.md` when more than one batch exists:

```text
# Upload Batches

Source: <path>
Target tool: <tool>
Aspect: 9:16

## Batch 01
- 01-hook.png
- 02-agent-reveal.png

Prompt file: batch-01.md

## Batch 02
- 05-confirmation.png
- 06-leaderboard.png
```

## Prompt Placeholders

If prompt files are requested but motion details are not ready, create placeholders with enough structure to fill later:

```text
# Batch 01 Motion Prompt

Intent:
Keyframe order:
Motion:
Preserve:
Avoid:
Stitch:
```

Do not invent a final prompt when the motion direction has not been approved.

## Verification

After copying, report:

- destination folders created
- number of images per folder
- overlap frames used
- manifest/prompt files created
- any missing or skipped source frames

## What Not To Do

- Do not delete originals.
- Do not overwrite existing accepted batches unless the user asks.
- Do not silently change frame order.
- Do not mix rejected frames into upload folders.
- Do not treat batching as creative approval.
