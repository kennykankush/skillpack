---
name: launch-narrative
description: Shape a product-launch or SaaS motion-graphics video into a tight narrative spine before storyboard frame generation. Use when the user is deciding the hook, flow, duration, voiceover, feature emphasis, or ad rhythm for a launch film. Produces beats and frame direction, not generated images.
---

# Launch Narrative - Product Film Spine

This skill turns a product idea into a short launch-video narrative before visual generation begins.

The goal is not to list product features. The goal is to find the emotional and functional rhythm that makes the product feel inevitable in motion.

## Activation

Use this skill for requests like:

- "what should the flow be?"
- "help me storyboard the product launch"
- "what is the 10 second version?"
- "is this narrative weird?"
- "should we mention leagues or friends?"
- "write the voiceover vibe"
- "I need a narrative-v2 / v3 / v4"

Do not use this skill for final frame generation, frame QA, file batching, or video rendering unless paired with the relevant skill.

## Preflight

Establish or infer:

- product truth: what the app actually does
- target user: who should care in the first 3 seconds
- core promise: the line that should survive every edit
- launch format: ad, teaser, app reveal, investor/product demo, social post, intro bumper
- duration: 3-6s, 10s, 15s, 30s, 60s, or 90s
- target platform and aspect ratio
- required product moments
- forbidden or weak moments
- brand tone: restrained SaaS, playful consumer, premium AI, sports-energy, editorial, etc.
- voiceover gender/tone if relevant

If multiple narratives are plausible, give 2-3 routes and recommend one.

## Narrative Shapes

Use these as starting points, not templates.

### 3-6 Seconds

```text
problem flash -> product action -> brand promise
```

Best for teasers, reels, and quick logo tags.

### 10 Seconds

```text
lonely/old way -> new agent/product action -> lock/confirm -> brand
```

Best for one clear product twist.

### 15-30 Seconds

```text
hook -> product setup -> product loop -> social/proof -> brand resolve
```

Best for launch ads and short product explainers.

### 60-90 Seconds

```text
world/context -> pain -> product system -> core workflows -> proof -> invitation -> brand
```

Best for fuller launch videos, not quick social clips.

## Strong Product-Launch Flow

A good launch film usually alternates between product demo and copy:

```text
copy plate -> product moment -> response/confirmation -> social/proof -> brand
```

Avoid a literal app tour:

```text
login -> menu -> settings -> dashboard -> everything else
```

The viewer should understand the product promise before they understand every screen.

## Beat Quality Rules

Each beat should answer one question:

- Why should I care?
- What is new?
- What can I do?
- What does the product do back?
- How does this become social or useful?
- What do I do next?

Cut beats that only exist because the app has a screen.

## Voiceover Rules

Voiceover should be short enough to survive music and motion.

Prefer:

- one idea per line
- verbs over explanation
- product truth over slogans
- exact brand pronunciation notes when needed

Avoid:

- dense feature narration
- generic AI claims
- "revolutionary", "seamless", "next-gen" unless the brand truly uses them
- repeating on-screen text word for word if the visuals already carry it

Example structure:

```text
You make the call.
Your agent pushes back.
Lock the pick.
Then see how your league stacks up.
```

## Output Format

Default to:

```text
Narrative Route: <name>
Core Promise: <one sentence>
Duration: <target>

Frame 01
Visual:
Voice:
Animation:

Frame 02
Visual:
Voice:
Animation:
```

For early discussion, do not over-specify every frame. Nail the feel and spine first.

## Decision Checks

Before handing off to `videos:storyboard`, confirm:

- the narrative does not make the product sound like a different app
- the hook is not too gimmicky
- the product twist appears early
- social or competitive behavior is included only if true to the app
- the final tagline is clear and brand-safe
- the frame count matches the target video duration

## What Not To Do

- Do not generate images.
- Do not lock into a fixed flow if the user is still exploring feel.
- Do not invent product features to make the ad sound bigger.
- Do not copy competitor/reference wording.
- Do not bury the core promise under onboarding details.
