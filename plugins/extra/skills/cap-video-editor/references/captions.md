# Caption the edited narration

Create cues from the final voice track as heard in the edited video. Caption timing must follow the current cuts, imported audio, and speed changes rather than an earlier script file or the uncut recording.

## Resolve the actual audio first

Inspect the audio tracks in the authoritative project. If the recording itself has no mic or system audio, a Cap build may hide **Generate captions** even though imported narration is audible on the timeline. That UI condition does not establish that the final mix is silent.

Render a baseline with the current audio when necessary. Use its audio as the timing reference. For speech recognition, prefer a narration stem with exactly that timing if music interferes. Do not accidentally transcribe an unused source recording track.

Extract a local alignment WAV:

```bash
ffmpeg -i baseline.mp4 -map 0:a:0 -ar 16000 -ac 1 alignment.wav
```

Check the available local speech aligner. One inspected `whisper.cpp` build supports word-level output through:

```bash
whisper-cli -m local_model.bin -f alignment.wav -l en \
  -dtw large.v3.turbo -nfa -ml 1 -sow -ojf -otxt \
  -of alignment -np -t 4
```

Use the model's matching DTW preset and the installed CLI's help. These flags are an adapter example, not a requirement to install that model. Inspect the resulting data before assuming its shape. In the inspected JSON, `offsets.from` and `offsets.to` are milliseconds, while Cap cue times use seconds.

Check which times track the speech before trusting either. On one narration, the per-word segment offsets drifted up to 1.8 seconds early. Each token's DTW time (`t_dtw`, in 10 ms units) stayed 0.1 to 0.3 seconds after the measured onset of every sentence. Compare both against a few known speech onsets. When DTW times lag slightly, pin each sentence's first word to the measured onset.

## Correct words without concealing a speech mismatch

Compare the recognized sequence with the clean spoken script. Restore known capitalization, punctuation, and product spellings when the audio supports them. Recognition can split a product name into two words; merge their time ranges when correcting it.

A wording mismatch can be a recognition error or an actual synthesis error. Check the audio before forcing canonical text onto different speech. If the voice says the wrong number or omits an essential word, repair the voice section and realign it.

Aligners sometimes attach punctuation across silence. A greeting's final word may appear to span the pause before “Today.” Check the waveform or playback, shorten the greeting cue to its actual speech, and start the next cue at the measured body onset. Never copy another project's pause timestamp.

## Group phrases for reading

Start with about five to eight words per cue and roughly 35 to 50 characters when they fit the actual canvas. Treat these as drafting aids, not mandatory lengths. Favor phrase and sentence boundaries, usable reading duration, and no overlap between cues.

A fixed word count splits set phrases such as “notice / period” or “general / counsel”. Break each sentence by least cost instead. Prefer breaks after punctuation. Avoid ending a cue on an article, a preposition, or the first word of a set phrase, and keep cue lengths within a sentence similar. Never let one cue hold the end of one sentence and the start of the next.

Avoid a one-word cue flashing at the end of a phrase. Merge it when the preceding cue remains readable, or rebalance the words. Do not leave a caption displayed through a long silent interval merely because an aligner assigned an overlong word.

Split groups at hard source cuts before mapping them into Cap's source domain. For a word that straddles a cut, use its actual spoken interval to assign and clamp it at the boundary; do not duplicate the word or extend it across removed source footage.

Preview the result at ordinary playback size. Per-word animation and highlighting are optional style choices. Default to stable phrases unless the user has chosen another treatment.

## Respect Cap's two timing domains

One inspected implementation uses these representations:

- `captions.segments`: source/recording-time caption segments
- `captions.sourceTimed`: true when those segments already use source time
- `timeline.captionSegments`: output-time cues projected through the current edit list
- `captions.settings`: style, enabled state, and subtitle export settings

The core shapes are:

```json
{
  "id": "cue_001",
  "start": 4.2,
  "end": 6.1,
  "text": "The reference opens the source page.",
  "words": [{"text": "The", "start": 4.2, "end": 4.35}]
}
```

This shape can occur in either domain; its enclosing field determines the meaning. The numbers above do not describe a complete cue's word list.

Verify the installed schema before writing it. In the inspected implementation, `sourceTimed: false` denotes legacy output-timed data that is migrated when loaded. Mixing already-converted source times with that flag shifts cues again. Treating output times as source times can map narration into deleted loading gaps.

For constant-speed source clip `[s, e)` beginning at output time `o`, map an output cue's time `t` with:

```text
source_time = s + (t - o) * speed
```

Perform the mapping within the owning clip. The same output boundary can refer to the outgoing clip's end or the incoming clip's start. Carry clip identity, not only a floating-point timestamp. Repeated source footage, reordered clips, recording-segment offsets, holds, and transitions require the editor's full mapping.

One inspected caption normalizer limits individual word duration to 2.5 seconds. A source-timed word accidentally stretched across a removed wait can be clamped or lost when the project reopens. Splitting at cuts and verifying a reopened staged project catches this failure.

The same implementation builds the displayed captions from the source-timed segments in four steps:

1. It splits each caption at every timeline segment edge, and a change of speed counts as an edge.
2. It rebuilds the displayed text from the words inside each piece.
3. It ends each piece at its last word.
4. It ends a caption no later than 2.5 seconds after its last word starts.

So a phrase that crosses an edge appears as two partial captions, even when you wrote it as one. Group words within each segment. Move segment edges into pauses between phrases where the edit allows. Lengthen each cue's last word for a readable hold, because that word's end is where the cue ends. Each cue also fades in from its start over the fade duration.

Preserve per-track overrides such as `positionOverride`, font size, color, and fade settings. Do not erase them when regenerating source-to-output projections.

## Verify visibility in the export

Confirm that captions are enabled and exported. In the inspected schema, those settings include `enabled: true` and `exportWithSubtitles: true`. Preserve the user's existing font, animation, weight, background, position, and highlighting unless asked to change them.

A manual position near the bottom margin, such as normalized `(0.5, 0.95)`, can work when the canvas has space there. It is not a universal safe area. Zooms can move source material beneath it; tables and PDF footers may require an alternate position for selected cues.

Check captions over these screens:

- The greeting and its pause
- A request or data-entry field
- A zoomed result
- A source page or dense table
- Both sides of every hard cut
- The concluding sentence

Save a standard output-timed SRT as a portable companion when useful. Cap's source-timed storage is not the SRT time domain. Reopen the staged project, render captioned previews, then inspect the final encoded video before claiming the subtitles work.
