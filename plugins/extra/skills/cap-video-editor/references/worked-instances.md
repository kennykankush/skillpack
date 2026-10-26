# Calibrate the workflow with different recordings

These instances tune the editorial decisions and tool boundaries. They are not the menu of allowed inputs. Rebuild the study, timing, and script from the actual footage each time.

## One instance: a short document-workspace demonstration

The material is a two-minute silent screen recording. It includes a selected report, an assistant request, a long processing wait, a grouped response, a source-page check, another wait, and a folder overview. The brief asks for a professional local voiceover, skipped loading, readable zooms, captions, and a finished Cap export.

Study at five-second intervals, then inspect the request submissions, first result frames, source-page opening, and final overview more closely. Do not derive the story from a transcript because there is no existing narration. Record the distinction between a visible source reference and proof of factual correctness.

The story is “an overview guides the next reading decision, and source references allow context checks.” It is not a tour of buttons. A possible middle passage is:

> The response groups the report's main themes and includes references to its pages. Opening a reference lets us read the surrounding material before relying on the summary.

Remove the processing waits in the cut plan. Generate a separate greeting and body, then synthesize the report request, report result, source check, folder request, and folder result as individually timed sections. Explain the folder's broader scope over a short remaining gap instead of leaving silence or reading a spinner.

Zoom to the selected item, the response, and the source page when they become relevant. Use fixed positions even if cursor tracking is absent. Caption the edited audio after any replacement opening is imported. Conclude with the practical use of the overview and references, rather than a sign-off.

The run fails if the voice describes the report result before it appears, captions follow the uncut timeline, or a zoom hides the referenced page. Repair the affected section and review the next anchor.

## One instance: a longer drawing lesson with original speech

The material is a twelve-minute tablet drawing lesson with the instructor's own narration. The brief asks for idle rendering waits to be removed, occasional zooms on line work, and captions. It does not request a new synthetic narrator.

Study the full sequence at an overview rate, then sample more densely around the strokes and layer changes discussed in the existing voice. Preserve drawing time that demonstrates the technique; an apparently quiet interval can be essential visual evidence. Remove idle rendering waits only where the speech and learning sequence remain coherent.

The story concerns how line weight distinguishes the foreground from the background. Do not replace the instructor with Cortana, manufacture a new introduction, or rewrite the spoken captions into business copy. Use the existing speech as the authoritative narration and derive captions from the edited audio.

Exact actions can be educational here. “Choose Multiply so the shading preserves the sketch underneath” teaches a control and its purpose. Reciting each stylus movement adds no such value.

A modest fixed zoom can reveal the line-width change. Check the low-magnification transition and retain enough surrounding drawing for orientation. Caption placement should avoid the instructor's active drawing area, including after a zoom. A requested concluding overlay or added voice line could explain how the heavier foreground lines clarify overlap, but only if that result appears in the lesson.

The run fails if cutting “dead time” removes the stroke being taught, a fresh voice replaces authorized original speech, or the captions conceal the drawing. Restore the relevant footage or framing and realign the affected audio and captions.

## Review cases before shipping a changed skill

Use these cases to inspect the skill's decisions. They are behavioral evaluation prompts, not claims that an automated agent test has run:

| Case | Required decision | Failure signal |
| --- | --- | --- |
| Three similarly named clips | Probe durations and study every clip separately | Claim all were watched after examining one |
| “Five frames” is ambiguous | Resolve sampling frequency | Silently choose 5 fps for a broad overview |
| Loading waits will be removed | Finalize output slots before fitting narration | Fit the script to the raw duration |
| Greeting runs into the body | Render pieces separately and insert measured silence | Add punctuation and claim the pause is fixed |
| Replace only the opening | Inspect current audio trims and preserve the body | Regenerate the entire accepted edit |
| No cursor track | Use a supported fixed manual target | Demand synthetic mouse events to place a zoom |
| A 1.3x zoom wobbles | Inspect scale and anchor during the transition | Call a sharp 2x still proof of smooth motion |
| Generate captions is hidden | Inspect imported narration and use final audio | Assume the demo has no audio |
| Captions move after reopening | Check timing domain and source-cut boundaries | Keep patching output numbers without mapping |
| Export requested at 1080p | Check canvas and measured encoded dimensions | Deliver a 1920-wide file with an unintended height |
| Metadata says audio is present | Inspect decoded signal and playback where possible | Claim the narration is audible from metadata alone |
| AI sample looks crisp | Inspect adjacent frames and exact text/numbers | Call deformed figures recovered detail |
| Heavy model has a long ETA | Identify any model change and compare its own sample | Substitute lite processing without disclosure |
| User rejects enhancement | Stop; preserve the accepted export | Continue experimenting or replace the good file |
| Original project changes during rendering | Merge scoped changes into the current state | Overwrite it with the staged snapshot |

For a real workflow evaluation, retain inputs, expected decisions, observed actions, output evidence, and any checks unavailable in the host. Static schema checks and this table alone do not establish end-to-end editing performance.
