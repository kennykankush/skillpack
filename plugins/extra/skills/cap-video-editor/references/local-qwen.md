# Generate narration with a saved local voice

Use the selected local voice preset and an already compatible runtime. The saved voice prompt, model, renderer, and any pronunciation conventions belong to the local installation; discover them rather than hard-coding their machine paths into the skill.

## Reuse the selected preset

If the brief selects Cortana, reuse the saved Cortana preset rather than approximating it with a different generic voice. Target a mature, professional, restrained delivery. Avoid theatrical elongation, breathiness, intimacy, or a childish register unless explicitly requested.

A Voicepack-style preset can contain `voice.json` and `voice.pt`. The serialized prompt requires a compatible Qwen base model and runtime; it is not a standalone synthesizer. Inspect the local runner's help or code before using it. Keep voice prompts and reference audio private.

Prefer an existing verified CLI or localhost service. Do not silently change the default voice of a shared running service. Use per-request voice selection if supported, or an isolated renderer.

## Keep a cached run offline

When the model is already cached, point at the resolved local model directory and disable remote lookups:

```text
HF_HUB_OFFLINE=1
TRANSFORMERS_OFFLINE=1
HF_HUB_DISABLE_TELEMETRY=1
TOKENIZERS_PARALLELISM=false
```

An Apple Silicon runtime may use `mps`, `float16`, and `PYTORCH_ENABLE_MPS_FALLBACK=1`. Verify support in the installed stack. Do not apply these device choices to another platform by rote. A missing cache is a missing dependency, not permission for an unannounced provider call or model download.

## Voicepack adapter, when its API matches

One inspected runner exposes `QwenRuntime` in `runners/qwen/serve.py`, with `render` accepting text, an output path, and a seed. This is an adapter example, not a stable upstream Qwen API.

Build the runtime from resolved paths and compatible settings:

```python
from types import SimpleNamespace

args = SimpleNamespace(
    voice=str(voice_directory), model=str(local_model_directory),
    language="English", device="mps", dtype="float16", seed=None,
    temperature=None, top_k=None, top_p=None,
    repetition_penalty=None,
)
runtime = QwenRuntime(args)
```

Import `QwenRuntime` from the inspected local runner using the selected environment. Do not assume the system Python has its dependencies. Keep one runtime loaded for the section batch rather than reloading the model for every sentence.

Render sections to WAV:

```python
result = runtime.render({
    "text": spoken_text,
    "output": str(section_wav),
})
```

Record small metadata such as model, voice, duration, sample rate, and elapsed synthesis time. Some adapters return raw audio bytes under a private field such as `_audio`; do not dump the whole response into logs or tool output.

This example uses the preset's seed default. Record an explicit override if needed. A fixed seed improves repeatability but does not guarantee identical output across model or runtime changes.

## Generate the greeting as two pieces

Do not depend on an exclamation mark or an ellipsis to create the desired pause. Render `Hello everyone!` and the following `Today, ...` sentence separately. Insert an explicit silence interval, such as 0.65 seconds, then measure the assembled opening.

Bracketed directions such as `[pause]` belong to the edit plan unless the selected TTS engine explicitly supports them as controls. Do not pass them as ordinary spoken text and hope they disappear.

Check the imported audio too. A pause that exists in the raw file can differ after encoding, trimming, or placement. Use the real edited mix when producing captions.

## Verify delivery, not only generation

For each section, establish these facts:

- The file exists, has nonzero duration, and contains audible speech
- The pronunciation and wording match the intended script
- Sentence endings are intact, without clipped consonants or abrupt joins
- The greeting has a deliberate pause before the body
- The fitted speaking rate remains intelligible
- Levels do not clip, and music does not mask the voice

Listen when playback is available. A local transcript can catch omitted or altered words, but it may mishear a product name or a short preposition. Resolve those differences against the audio rather than blindly editing either the script or the captions.

Keep raw and fitted sections until the final export passes. Save the authoritative final WAV and any requested preview format. MP3 is a convenience preview, not an automatic replacement for the WAV used to align and edit narration.
