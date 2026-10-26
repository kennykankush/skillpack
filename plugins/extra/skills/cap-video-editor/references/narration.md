# Write narration that fits the recording

Develop the explanation from inspected footage, then fit it to the edited timeline. The script should help the viewer understand the task and its result without requiring a spoken account of every cursor movement.

## Recover the point before writing sentences

For each section, record these facts:

| Field | What to establish |
| --- | --- |
| Visible evidence | The inspected screen and its source timestamp |
| Viewer question | What the viewer needs to understand at this point |
| Intent | Why the person takes this action |
| Result | What changes visibly |
| Significance | How that result helps the task |
| Limit | What the recording does not establish |

The significance must follow from the evidence. A reference link allows inspection of a cited source; it does not establish that every statement is correct. A successful export shows that a file was produced; it does not establish the source figures' accuracy.

## Use a story with room to breathe

The default progression is greeting, context, task, result, visible validation, and takeaway. Adapt it to the actual footage rather than manufacturing missing stages.

An opening can sound like this:

> Hello everyone!
>
> [Measured pause, not spoken]
>
> Today, we'll see how a folder overview helps us decide which documents deserve a closer read.

The middle explains purpose and consequence:

> Selecting one report keeps the request focused. The response groups its main themes and includes page references we can open for context.

A concluding sentence states the overarching point:

> The overview helps us choose where to read next, while the references give us a route back to the original material.

These are calibration examples, not required product copy. Do not insert a feature, source reference, or verification step that the inspected recording does not show.

## Avoid a cursor transcript

Choose narration that answers a viewer's question:

| Cursor transcript | Explanation anchored to the same action |
| --- | --- |
| “Now I move here and click this report.” | “Selecting one report keeps the summary focused on that document.” |
| “The spinner is loading. We wait.” | Cut the long wait; use a short remaining gap to explain the request's scope. |
| “I click the blue link.” | “Opening the reference lets us compare the summary with its source page.” |
| “Scroll down, then scroll down again.” | “The response separates the documents, making it easier to choose what to review next.” |

Teach exact controls when the audience needs them. A training lesson may need “Choose Multiply so the shading preserves the sketch underneath.” It still explains the reason, instead of enumerating movements with no learning purpose.

Do not fill time with generic benefits, fabricated guarantees, repeated recaps, or implementation details the viewer cannot use. Small gaps can explain scope, the relation between two stages, or what to check next. Keep natural breaths; eliminate unnecessary dead air rather than demanding uninterrupted speech.

## Fit narration after the cut plan

Distinguish source time from output time. For a retained source range `[s, e)` played at speed `r`:

```text
output_duration = (e - s) / r
output_start = sum(previous retained output durations)
output_end = output_start + output_duration
source_time = s + (output_time - output_start) * r
output_time = output_start + (source_time - s) / r
```

Use the active edit list, not the uncut recording's timestamps. Holds, transitions, repeated clips, multiple recording segments, and speed ramps require the installed editor's actual mapping; the constant-speed formula alone does not model them.

Store per-section decisions in a plan:

```json
{
  "sections": [{
    "id": "result",
    "output_start": 18.4,
    "output_end": 26.4,
    "visible_anchor": "Grouped response first appears",
    "anchor_output_time": 18.6,
    "source_clip_id": "clip_b",
    "text": "The response separates the main findings..."
  }]
}
```

Numbers and text in this example are illustrative. Derive the real slots from the footage. Keep operational notes out of the clean spoken script.

Generate and fit each section independently. A rough word budget can help drafting, but measured synthesis duration decides whether it fits. Prefer a rewrite when the speaking rate sounds rushed or unnaturally stretched.

The pitch-preserving tempo factor is `raw_duration / target_duration`. Render a candidate section to a new WAV, then measure it:

```bash
ffmpeg -i raw.wav \
  -af 'atempo=1.06,apad,atrim=duration=8.0' fitted.wav
```

Here `1.06` and `8.0` are examples, not defaults. Do not use a target duration that cuts off the last word. A starting preference is to keep tempo changes within about 10 to 15 percent; speech quality is the gate, not compliance with that range. Rewrite, change a legitimate hold, or regenerate if the section still fails.

Assemble the fitted sections at their planned output times. A long narration file followed by global time stretching will drift when sections have different speaking rates or removed waits.

## Repair the smallest affected section

For an opening-only request, determine the exact replacement slot from the current project. Preserve the rest of the narration and the user's music and trims. Render the greeting separately from the first explanatory sentence, insert silence, and fit the combined opening to that slot.

Measure the pause in the imported or exported audio as well as the raw WAV. Format conversion, added silence, trims, or the user's edits can change the actual timing. Do not reuse an old “Today starts at...” number without checking it.

After any edit, inspect the opening, each section boundary, each result's appearance, and the closing sentence. A section-local repair must not shift later sections. If perceptual audio playback is unavailable, report that limit; waveform analysis and speech recognition are useful checks, not a listening claim.
