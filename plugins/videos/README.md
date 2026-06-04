# Videos

Opinionated video preproduction workflows for product-launch storyboards, motion-design frame direction, and AI-video-ready shot batches.

## Install

### Codex

From the `skillpack` repo:

```
codex plugin marketplace add .
```

Restart Codex, open `/plugins`, install `videos`, and start a new thread. Codex invokes these as bundled skills such as `$videos:storyboard`, `$videos:launch-narrative`, `$videos:style-contract`, `$videos:frame-qa`, `$videos:batch-prep`, and `$videos:motion-handoff`.

### Claude Code

```
/plugin install videos@kennykankush-skillpack
```

Requires the `kennykankush-skillpack` marketplace added first.

## Skills

- `videos:storyboard` - creates cohesive storyboard frame sets for product-launch motion graphics using Codex imagegen, with prompt logging and frame-by-frame quality gating.
- `videos:launch-narrative` - shapes the hook, promise, voiceover, and beat flow before frames are generated.
- `videos:style-contract` - distills screenshots, brand assets, and references into a reusable visual contract for cohesive generation.
- `videos:frame-qa` - reviews generated frames/contact sheets and gives keep/regenerate decisions with targeted notes.
- `videos:batch-prep` - copies accepted frames into upload-ready AI-video batches with manifests and prompt placeholders.
- `videos:motion-handoff` - writes AI-video keyframe prompts and node workflows for tools like Higgsfield Canvas, Gemini/Omni, Runway, and Krea.
