---
name: cap-video-editor
description: >-
  Turn existing screen recordings into coherent narrated demos in Cap Studio.
  Use when asked to study video frame by frame, write a script that explains the
  bigger picture instead of reciting cursor movements, sync narration around
  edited loading waits, generate local Qwen or Cortana audio, add manual zooms
  without mouse tracking, add subtitles, or finish and verify a Cap export.
---

# Edit a screen recording into a narrated demo

Study what the recording actually shows, build an explanation around its visible results, and fit the narration to the edited timeline. Finish in Cap with deliberate zooms, readable subtitles, and a verified video. Enter at the requested stage; preserve the work already in the project.

## When to activate

Use this workflow for requests such as:

- Study this recording at intervals, then develop the script
- Make the narration sync with these result screens
- Explain the bigger picture during the small gaps
- Skip the assistant loading; keep the explanation flowing
- Use the saved Cortana voice through local Qwen
- Add zooms where they help, even without cursor tracking
- Add captions and re-export the existing Cap project
- Regenerate only the greeting, or continue the next demo in the same style

## When to use another workflow

Route a net-new launch film or generated storyboard to the Videos skills. Use a transcription workflow when the only deliverable is a literal transcript. Use an application-engineering workflow for Cap source changes or packaging; this skill can diagnose the editing limitation and supply the reproduction, but it does not authorize an app rewrite.

If the video, project, or required local runtime is inaccessible, finish any independent study or script work and name the missing input. Do not claim to have watched inaccessible footage, synthesize unseen results, or upload private recordings to solve a local limitation.

## Establish the brief and current state

Resolve these inputs from the request and workspace before asking questions:

- Which recordings, in which order, and which existing Cap project is authoritative
- Audience, intended takeaway, language, and requested deliverables
- Whether to preserve existing speech, replace it, or add selected sections
- Voice preset and local synthesis runtime when narration is requested
- Which loading waits can be shortened or removed
- Output destination, canvas dimensions, frame rate, and caption format
- Existing cuts, zooms, music, imported replacement audio, and caption styling

Ask only for a consequential missing choice. “Five frames” needs clarification if it could mean five frames per second or one frame every five seconds. A clear instruction to add captions or overwrite an export already authorizes that scoped work; do not ask again.

Keep the workflow portable across agent hosts. Discover local tools and paths; do not assume a particular username, cache snapshot, app profile, provider endpoint, or custom Cap build. Use `ffmpeg`, `ffprobe`, an image viewer, Cap's available controls or CLI, and the selected local voice runtime. Local speech alignment is optional when usable timings already exist.

## The editorial rule

**The screen is the evidence; the narration explains its significance.**

Build each section around intent, a visible action or result, and why that result matters. Synchronize at those anchors rather than narrating every movement. A small gap can explain scope, context, or the next decision. It does not need an empty pause or filler about waiting.

The worst failure is a polished voiceover that describes the wrong screen or claims capabilities the recording never demonstrates. Guard against it with a timestamped study, an explicit source-to-output cut map, section-level audio fitting, and checks of the exported result. Neither a fluent script nor a successful render proves synchronization.

## Workflow

### 1. Inventory and study every requested recording

Probe each file for duration, dimensions, audio streams, average and nominal frame rates. Match ambiguous filenames using measured durations and inspected content. Preserve originals; organize copies or references into descriptive per-demo folders.

Start with one frame every five seconds for an overview when that matches the brief. Inspect the actual images, not only filenames, generated contact sheets, or OCR output. Revisit important clicks, result appearances, page changes, and cut boundaries with denser samples or short playback. Inspect text at full resolution when a contact sheet cannot resolve it.

Use [the study helper](scripts/study_video.py) to create a local inventory and timestamped samples:

```bash
python3 path/to/cap-video-editor/scripts/study_video.py \
  --output work/study --interval 5 recording_a.mp4 recording_b.mp4
```

The helper marks every image as unreviewed. Add observations after inspecting them. Distinguish what is visible, what you infer, and what remains unknown. Finish one study entry per recording before claiming all videos were reviewed. Sampling does not prove continuous playback or audio comprehension.

The helper preserves existing output directories. For a denser follow-up, use a new study directory and repeat `--at` for selected timestamps. A source with variable frame timing can yield a nearby frame; the manifest records requested seek positions, not measured presentation timestamps.

When continuing a demo series, reuse the approved voice, opening rhythm, caption style, music treatment, and zoom restraint. Study the next recording independently and derive its own story, cuts, and cue times. Never carry factual narration or timings across merely because the demos look similar.

### 2. Recover the story and plan the cuts

Write a compact study: opening state, request or task, processing waits, first visible result, validation or source check, and final state. Identify the overarching point before drafting narration.

Create a cut map with source ranges, playback speed, and resulting output ranges. If loading is to be skipped, finalize that map before fitting audio. Preserve enough context to understand the request and response. Cut waiting, not evidence needed to understand the demonstration.

Allow brief result holds for reading or a conclusion. Prefer a shorter script when the footage cannot support the duration. A freeze or speed change must remain an intentional edit; do not invent additional activity.

### 3. Write narration for understanding

Use [the narration guidance](references/narration.md) for the full writing and timing method. Default structure:

1. Greeting, a measured pause, and what the audience will learn
2. Context and the task being attempted
3. Selected actions that explain the workflow
4. Visible results, their meaning, and any visible validation
5. A conclusion that states the practical takeaway

Avoid a cursor transcript: “Click here, move over, click that.” Explain purpose and consequence instead. Keep specific operating instructions when they are the learning objective. Do not read the entire interface aloud or turn every small gap into a pause.

Close on the result's significance, not a default “thank you for watching.” Keep claims bounded by the footage. A generated document using supplied figures does not prove autonomous extraction; a permissions answer does not prove access enforcement.

Assign each spoken section an output-time slot and visible anchor. Keep the clean script separate from production notes, cut instructions, and timestamps.

### 4. Generate or preserve narration, then fit it by section

Reuse the selected voice and the latest project audio. An imported replacement opening can supersede the older full narration file. Inspect the actual audio tracks and trims before regenerating anything.

For local Qwen with a saved Cortana preset, follow [the local voice reference](references/local-qwen.md). Render the greeting and the following sentence separately when punctuation produces a run-on delivery. Insert measured silence between them; bracketed pause directions are production notes, not text to synthesize blindly.

Generate sections independently. Measure each render, fit modest differences with pitch-preserving time stretch, and place it in its output slot. Rewrite or regenerate a section that needs an unnatural speaking rate. Check section joins, sentence endings, clipping, and the actual pause after the greeting. Never concatenate an unmeasured script and expect it to match footage with removed waits.

If only the opening is requested, deliver that replacement at the required length. Preserve the remainder of the voiceover and edit.

### 5. Apply the edit and purposeful manual zooms in Cap

Follow [the Cap reference](references/cap.md). Copy the complete `.cap` project before opening, inspecting through mutating APIs, or editing configuration. Capture the original configuration and a hash. Work in the copy, render previews, then merge only the requested verified fields into the authoritative project. Recheck for concurrent edits before writing.

Keep existing user cuts, music, voice trims, zooms, crops, and styling unless the task requires changes. Prefer a working installed CLI over rebuilding the app for an export.

Use manual positions for imported recordings that have no useful cursor track. Frame the subject the viewer should read: a selection, result, citation, permission list, or table. Start after the target is visible, hold long enough to read, and return to context when attention changes. Do not chase every cursor movement.

The intended transition has a fixed anchor, monotonic scale, and no spring overshoot or wandering. Check both low magnifications such as 1.2x and 1.5x and larger zooms. Distinguish picture wobble from dropped playback frames. Inspect before, during, and after the transition, with playback when available. A still at full zoom cannot establish smooth motion.

If the installed version lacks fixed manual anchors, verify its supported schema and controls. State the limitation instead of inventing fields. Keep any authorized app fix separate from the demo edit, and distinguish source changes, a built artifact, an installed app, and observed runtime behavior.

### 6. Create subtitles from the edited audio

Follow [the caption reference](references/captions.md). Align against the actual assembled narration and its final timing, including imported openings, section speed changes, and trims. Do not transcribe an empty original recording track merely because it is easier to select.

Correct spelling and product names against the script after checking the spoken words. Group readable phrases and avoid flashing a single trailing word. Split timing groups at hard cuts. Preserve the user's caption style; otherwise use restrained, legible text with adequate contrast.

Preview captions against the content at each zoom level. Move them when they obscure a table, figure, important field, or source citation. Deliver an SRT when useful, and confirm that the requested burned captions appear in the exported video.

### 7. Export, verify, and deliver

Set both the canvas aspect ratio and export dimensions. A request for 1920x1080 can otherwise produce a cropped-aspect file with a different height. Check the file with `ffprobe`; an export setting or completion notification is insufficient.

Check the actual output's dimensions, frame rate, duration, audio, captions, cut joins, result anchors, greeting, conclusion, and zoom transitions. Decode the complete file to catch corruption. When only visuals changed, compare the exported audio with a verified baseline. State any unavailable perceptual checks honestly.

For an authorized overwrite, retain a backup, render to a separate path, validate, then replace the named export. Keep an enhancement experiment separate from an accepted video. Report the delivered path and material limitations without recounting every tool call.

### 8. Treat enhancement as an optional experiment

Use [the enhancement guidance](references/verification-and-enhancement.md) only when requested. Higher export resolution does not recover erased screen text. Image upscaling of extracted frames is not a temporal video restoration model.

Compare representative text, numbers, motion, and consecutive frames before a full run. Benchmark time and storage. If a faster model replaces the sample's model, identify that change and evaluate its own sample; do not imply the full result uses the accepted model. Preserve original timestamps and audio when rebuilding footage.

Reject sharpening that warps letters or figures, even if edges look crisper. Do not call altered numerals recovered detail. If the result is rejected, stop that experiment and retain the accepted export.

## Output and resumable handoff

Use the existing project structure. A new project can use these roles without requiring these exact filenames:

```text
demo/
  source/                 originals or explicit references
  study/                  inventory, sampled images, observations
  edit-plan.json          source cuts, output slots, visible anchors
  script.txt              spoken words only
  narration/              raw sections, fitted sections, final WAV
  subtitles/              timed cues and SRT
  project.cap/            editable working project
  exports/                verified video and any comparison version
  receipt.json            settings, checks, paths, limitations, backups
```

Do not rebuild everything for a caption-only or greeting-only request. Record the active project, authoritative audio, current cut map, completed checks, next action, and any unresolved limitation so another turn can continue at the right stage. State whether the result reused an existing edit or was built from source. Do not write private machine paths or client material into this distributed skill.

## Quality gate and redo conditions

A requested stage passes only with its corresponding evidence:

- **Study:** every requested clip has inspected timestamped observations. Metadata or unviewed samples alone fail; inspect the missing footage.
- **Script:** every material claim has a visible anchor, the opening establishes purpose, and the ending states a takeaway. A click transcript or unsupported capability claim fails; rewrite it.
- **Sync:** the final cut map and actual audio slots agree, results are visible when described, and the greeting has its intended pause. Drift or clipped words fail; repair the affected section and recheck later anchors.
- **Zooms:** manual framing works without a tracker and the transitions have been inspected. Wobble, obscured content, or untested motion fails; fix or remove the affected zoom and report unverified playback honestly.
- **Captions:** cues match the edited audio, survive reopening, and remain readable without covering essential content. Shifted or disappearing cues fail; correct the time domain and rerender.
- **Export:** measured dimensions, frame rate, duration, audible tracks, subtitle visibility, and full decode match the request. A successful command alone fails; inspect the file.
- **Preservation:** unrelated current edits remain intact and authorized replacements have backups. A stale project overwrite fails; restore and merge from the current configuration.

Static validation of this skill does not prove those behaviors. Use [the worked instances and review cases](references/worked-instances.md) to evaluate routing and judgment.

## Boundaries to keep

Keep confidential recordings, voice prompts, and project assets local unless their exact external use is authorized. A local voice preset does not authorize new paid synthesis or cloning another person. Do not print credentials, copy private assets into the plugin, install global skill symlinks in place of plugin discovery, or publish a video as part of exporting it.

Do not label sampling as continuous viewing, generated audio as listened-to audio, source code as a shipped app fix, or spatial enhancement as verified temporal restoration. Respect a request to stop or abandon an experiment.
