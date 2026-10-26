# Edit and render the current Cap project

Use the current project's schema and the installed application's supported controls. The configuration examples below describe an inspected Cap implementation; they are not a promise that every release or custom build uses the same fields.

## Discover the working editor and export path

Locate the actual `.cap` directory, application, profile, and CLI. Official and custom app builds can use different recordings libraries. The app currently open is not necessarily the app whose binary you found first.

On macOS, an installed application can bundle `cap-cli` under `Contents/MacOS/`. Check the installed binary:

```bash
cap-cli --help
cap-cli project --help
cap-cli export --help
cap-cli export-preview --help
```

Prefer a working native CLI for previews and exports when its capabilities match the project. Do not launch a source build merely to render a project. If the command or schema differs, adapt to the local help and code rather than adding invented flags.

## Preserve the entire project

A `.cap` project can be a directory containing `project-config.json`, `recording-meta.json`, media, cursor events, imported audio, screenshots, and other assets. Copy the complete directory. Copying only the configuration can break relative paths or omit the user's replacement narration.

Before editing, retain these facts:

- The authoritative project path and configuration hash
- An untouched configuration backup
- Current timeline segments and their speeds
- Audio paths, enabled flags, trims, placement, gain, and fades
- Zooms, source crop, background, caption style, and per-cue overrides
- Any shared assets referenced outside the project directory

Opening or inspecting a project through the application can normalize and save its configuration. Use the staged copy for that inspection too. Before merging a finished change, compare the authoritative configuration with the captured version. If it changed, preserve the new edits and rebase the scoped change. Never overwrite a newer project with a stale clone.

For caption-only work, merge captions and the corresponding timeline cues, plus an explicitly requested canvas change. Do not replace audio tracks or zooms as a side effect.

## Understand the timeline domains

One inspected schema represents retained recording ranges as:

```json
{
  "timeline": {
    "segments": [{
      "recordingSegment": 0,
      "start": 2.0,
      "end": 22.0,
      "timescale": 1.0
    }]
  }
}
```

The source range is `[start, end)`. Determine how this version maps audio, zooms, captions, and holds into output time. Do not assume all timeline arrays use the same domain because they share a parent object.

Imported audio can have its own output placement, `trimStart`, volume, and enabled state. An opening imported from MP3 can replace only the first portion of an older WAV. The current project arrangement decides which voice is authoritative.

## Use fixed manual zoom targets

Manual zoom positions in one inspected schema use normalized coordinates:

```json
{
  "start": 12.0,
  "end": 16.0,
  "amount": 1.5,
  "mode": {"manual": {"x": 0.2, "y": 0.35}}
}
```

This illustrates the mode shape, not a complete project patch. Preserve required fields and validate against the installed schema. Confirm the zoom's time domain using a preview at a known event. A mouse recording or synthetic click track is unnecessary when this version supports a fixed manual mode.

Place zooms around moments that benefit from readable detail. Keep the target away from a crop edge unless the result stays visible throughout the transition. Normalize the point against the correct source or crop coordinate system; do not guess from the output canvas.

Treat scale and translation as one framing decision. A transition should approach the chosen point without overshooting, reversing, or chasing cursor samples. Avoid adjacent zooms that retarget while the previous transition is still settling unless that motion is intentional.

For wobble, inspect these causes separately:

| Observation | What to investigate |
| --- | --- |
| Scale overshoots and returns | Spring response or easing |
| Center moves during a fixed zoom | Cursor interpolation, changing target, crop mapping |
| Movement occurs only between adjacent zooms | Overlapping transitions or retargeting |
| Still framing is correct but playback skips | Decode/render load or playback performance |
| Low magnification shakes more visibly | The actual 1.2x and 1.5x transition, not only a 2x hold |
| Export differs from the editor | Export renderer, settings, or the wrong application build |

A monotonic ease over a measured transition can be the intended behavior. Do not call a particular spring constant or source patch a proven fix without testing the actual installed renderer. A pending implementation, a passed unit test, a debug build, and a packaged application are separate states.

If app engineering is explicitly requested, retain a focused reproduction: project, anchor, magnification, transition times, observed wobble versus frame skipping, application version, and a short before/after render. Keep unrelated source changes intact. Do not silently turn demo editing into app maintenance.

## Render frames without dumping image data

One inspected `export-preview` command accepts a render settings object distinct from the full MP4 export settings:

```json
{
  "fps": 60,
  "resolution_base": {"x": 1920, "y": 1080},
  "compression_bpp": 0.3,
  "cursor_only": false
}
```

Pass the validated object through `--settings-json` and select `--frame-time`. Capture stdout in a local process. If the response contains `jpeg_base64`, decode it into an image file and inspect that file. Do not print the encoded image into logs.

Review the greeting, each result, each source cut, several zoom transitions, captions over dense content, and the conclusion. Preview frames establish framing and placement; use consecutive frames or playback to judge motion.

## Set the canvas as well as the export resolution

In one inspected schema, `aspectRatio: "wide"` selects a 16:9 canvas. A null aspect ratio can preserve the cropped source's proportions, producing an output such as 1920x882 even when the export base is 1920x1080.

For a requested 1080p file, set the supported 16:9 canvas option and export to a staged destination:

```bash
cap-cli project validate project.cap --json
cap-cli export project.cap --output candidate.mp4 \
  --fps 60 --resolution 1920x1080 --quality maximum --json
```

Inspect both process exit and terminal progress events. Progress can end with an error instead of completion. Measure the encoded output with `ffprobe` and decode it before replacing an existing video.

Keep the intended content proportions. Adding canvas background can satisfy a 16:9 delivery without stretching the source. Do not claim that a 60 fps export creates additional captured detail from a lower-frame-rate source.
