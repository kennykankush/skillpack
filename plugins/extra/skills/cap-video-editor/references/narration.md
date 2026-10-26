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

The closing section states what the feature is for, at a higher altitude than any step:

> So that's file and folder summaries. A reviewer can see what a whole collection covers before reading it, and every point still leads back to the page it came from.

These are calibration examples, not required product copy. Do not insert a feature, source reference, or verification step that the inspected recording does not show.

## Pair what is on screen with why it matters

Give every beat the same cadence. First name the visible action or result briefly, so the viewer knows where to look. Then give its purpose or consequence. At section turns, add the bigger picture: how this step serves the task, or what it changes for the audience.

Either half alone fails. A cursor transcript describes movement without meaning. A purpose statement with no visible action behind it loses the viewer, who cannot tell which part of the screen is being explained.

| Cursor transcript | What is on screen, with why it matters |
| --- | --- |
| “Now I move here and click this report.” | “Selecting one report keeps the summary focused on that document.” |
| “The spinner is loading. We wait.” | Cut the long wait; use a short remaining gap to explain the request's scope. |
| “I click the blue link.” | “Opening the reference lets us compare the summary with its source page.” |
| “Scroll down, then scroll down again.” | “The response separates the documents, making it easier to choose what to review next.” |
| “Two files appear in the list.” | “Both new files appear in the list already, so nobody has to upload them by hand.” |

Teach exact controls when the audience needs them. A training lesson may need “Choose Multiply so the shading preserves the sketch underneath.” It still explains the reason, instead of enumerating movements with no learning purpose.

## Close on the feature's purpose

Write the closing as its own section of about 10 to 20 seconds, not a sentence squeezed into the final second.

- Open with a wrap-up line that names the feature, such as “So that's folder sync.”
- Then state, at a high level, what the feature is for: the problem it removes and what it changes for the audience.
- Leave out mechanics, button names, and step order. The video has already shown them.

| Step recap (too granular for a closing) | Purpose (closing altitude) |
| --- | --- |
| “A file is saved into the folder, a sync sends it up, and the next answer uses it.” | “So that's folder sync: the assistant answers from the latest documents, and nobody changes how they work to keep it current.” |
| “We selected a report, opened a citation, and checked the cited page.” | “So that's source-linked summaries: an overview you can act on, because every point leads back to its page.” |

A purpose statement is still a claim, and it must be true of what the product does. Keep it formal and free of slogans.

Make room for the closing in the edit. If the footage ends before the closing does, hold or slow the final static screen, or append unused static footage from the same recording. Leave a short tail after the last word for the music to resolve.

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

When sentences in one section must land on different screens, render and place them one sentence at a time. Express each start relative to its visual anchor, for example 0.2 seconds after the answer appears, rather than as an absolute time. Then a change to an earlier cut moves every later slot with it. Trim each render's leading and trailing silence before placing it, and measure the gaps between sentences as part of the pacing.

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
