# Verify the export and evaluate enhancement

Measure the delivered file and inspect the behavior the viewer will experience. Keep export correctness, perceptual quality, and AI restoration claims separate.

## Check the encoded video

Use `ffprobe` to establish the actual output properties:

```bash
ffprobe -v error -show_entries \
  stream=codec_type,codec_name,width,height,r_frame_rate,avg_frame_rate,duration,nb_frames:format=duration,size \
  -of json candidate.mp4
```

Check the video stream's measured dimensions and frame rate against the request. Confirm duration against the output timeline, allowing only the expected frame and audio-packet rounding. A difference of seconds needs investigation rather than an assumption about encoder rounding.

Decode the complete export:

```bash
ffmpeg -v error -i candidate.mp4 -f null -
```

A clean decode establishes that the file can be decoded. It does not prove that the narration, text, or zooms look right.

Review playback or dense samples around each semantic anchor, cut, and zoom transition. Check the opening and closing speech, caption placement, source readability, and any ending hold. If the available tools cannot play or listen, state which perceptual checks remain unverified.

## Confirm the audio survived

An audio stream can exist and still contain silence. Inspect decoded level and duration, and listen when possible. If audio is missing, check track enablement, placement, source path, trim offsets, mute settings, gain, and the player's selected track or output device. Do not regenerate a good voiceover before locating the missing link.

When only visuals changed, decode baseline and final audio to the same PCM format and compare them:

```bash
ffmpeg -v error -i baseline.mp4 -map 0:a:0 \
  -c:a pcm_s16le -f md5 -
ffmpeg -v error -i candidate.mp4 -map 0:a:0 \
  -c:a pcm_s16le -f md5 -
```

Matching decoded hashes establish exact PCM identity for those decodes. Different lossy encoders can produce different samples from the same source; if hashes differ, inspect time offset, waveform agreement, levels, and audible content rather than declaring either identity or corruption from the hash alone. Do not claim a listening check from an audio fingerprint.

When narration was added, cross-correlate the export's audio with the narration stem. The offset should be zero, which also confirms that captions aligned on the stem fit the export. A transcript of the final mix is a useful content check, but a recognizer can add words on music-only stretches, such as an invented sign-off, or garble a phrase after a long pause in long-form mode. Before treating either as an audio fault, transcribe the suspect window on its own and compare its level with the narration stem.

## Replace only the authorized target

Retain the previous export and the original project configuration. Render and validate a candidate at a separate path. Before replacing the target, confirm it has not changed since the backup. Use an atomic same-filesystem replacement where supported.

Keep the current editable project's unrelated changes. The deliverable is the named verified video plus the requested editable changes, not a stale snapshot that discards user edits. A new enhancement comparison does not need to replace an accepted export.

## Decide whether an enhancement test is warranted

Probe the original footage before choosing a method. A low-bitrate 720p screen recording can contain text that has already lost its letter shapes. Scaling to 1080p or 4K changes pixel count; it does not establish recovered information. Export frame rate also does not recover captured frames without a separate interpolation step.

If enhancement is requested, state the concrete experiment and keep it local when the footage is confidential. Select representative samples containing large UI labels, tiny citations or filenames, numbers, a PDF or table, motion, and static content across consecutive frames.

Compare at the intended viewing size, with the same crop and timestamps. Enlarged isolated samples can flatter sharpening while hiding deformed letters or changing digits. A sharper wrong number is a failed result.

## Distinguish image models from video restoration

An image upscaler can process extracted frames and rebuild a full video. Call that frame-by-frame image enhancement, not a model that reasons across time. Check flicker, unstable text, cursor edges, scene changes, and scrolling. One good frame is not video qualification.

A dedicated video restoration tool can be another candidate, but verify its current capabilities and local processing path before recommending or using it. Do not infer temporal quality from its name, install a paid application silently, or upload confidential footage to a web enhancer without exact authorization.

Benchmark several consecutive frames before committing to a full run. Estimate:

```text
processing_time = measured_seconds_per_unique_frame * frames_to_process
storage_budget = input_frames + output_frames + intermediates + final_exports
```

The model is part of the experiment. If the accepted sample used a high-fidelity model, do not silently replace it with a lite model for the full video. Explain a material runtime tradeoff, compare the replacement model's own sample, and resolve the choice before dependent work when the intended quality is unclear. Reuse the accepted model when practical.

## Preserve time when reconstructing frames

For variable-frame-rate footage, retain the source frame timestamps. Writing the images back at an arbitrary constant frame rate can change duration and desynchronize narration. Encoding every 60 fps output duplicate is unnecessary if the source contains fewer distinct frames.

A reconstruction can reuse identical enhanced images while preserving every displayed frame's time. If processing only retained source ranges, include boundary frames and maintain the original source time domain, or explicitly remap every dependent timeline object. Do not mix those approaches accidentally.

If source dimensions double before re-entering Cap, scale pixel-based crop positions and sizes accordingly. Keep normalized manual zoom and cursor coordinates normalized. Verify the renderer's coordinate conventions rather than multiplying every number in the configuration.

Render the background, captions, and other clean overlays after enhancing the screen footage. Keep narration and music unchanged. Validate reconstructed frame timestamps, final dimensions, frame rate, duration, audio, captions, and complete decode.

## Recognize and preserve a failed experiment

Review a full comparison separately from the accepted video. Larger text can look cleaner while small text and financial figures become less faithful. Record that outcome directly; do not present it as a successful restoration because the pipeline ran.

If the viewer rejects the result, stop enhancement work and keep the accepted export intact. Retain useful evidence and follow the workspace's cleanup rules for owned intermediates. Do not delete other work, continue paid experiments, or treat rejection as a request for another unbounded search.
