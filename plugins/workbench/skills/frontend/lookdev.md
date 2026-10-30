# Look development

A VFX-pipeline lens for the visual layer. Shaders, textures and effects are tools; what makes a surface feel rich is treating it like a shot: light it, give things materials, composite the layers, grade everything to one look, and finish with a lens. Decide these in the system step so effects serve one look instead of piling up.

## Lighting

- Pick one light direction and keep it. Highlights on top edges, shadows falling the same way, gradients brighter where the light is.
- Light as a gradient: a soft radial glow behind the hero or key element, not a uniform background.
- Glows should be tight and low-opacity; a wide saturated glow reads cheap.
- Rim light: a 1px lighter top or inner border on cards and buttons sells depth on dark UIs.

## Materials

Give each surface type one material and reuse it.

| Material | How |
|---|---|
| Matte | Flat fill, soft shadow |
| Glass / frosted | `backdrop-filter: blur()` + low-alpha fill + 1px highlight border + faint noise |
| Gloss | Subtle vertical gradient, top highlight, tight shadow |
| Metal / chrome | Gradient bands, sharp highlight; Paper Shaders liquid metal for hero use |
| Paper / grain | Noise texture overlay at very low opacity |

## Texture

- Noise and grain (SVG `feTurbulence`, fffuel, a tiled PNG) at 2-6% opacity removes the flat digital look and hides gradient banding.
- Patterns (dot grids, lines) must be even, subtle and fade at the edges.
- Texture on large surfaces only; never on text or small controls.

## Depth and compositing

- Build in layers: background (shader, gradient, texture), midground (content surfaces), foreground (floating UI, overlays). Each layer has its own blur, contrast and shadow strength.
- Shadows as a system: two or three elevation levels, each a layered shadow (a tight dark contact shadow plus a wide soft ambient one), tinted toward the background colour, not pure black.
- Atmospheric depth: things further back are lower contrast and slightly blurred.

## Colour grading

- One grade across everything: UI colours, photography, illustration, 3D and video all pulled toward the same palette (duotone, tinted shadows, consistent warmth).
- Work in OKLCH (`culori`) for even ramps; keep saturation in check and let one accent carry.
- Dark UIs: avoid pure black and pure white; use tinted near-black and off-white.

## Lens and post

Apply sparingly, globally, and only when the direction calls for it.

| Effect | Tool |
|---|---|
| Grain | Noise overlay, Paper Shaders grain |
| Bloom | `postprocessing` (3D), CSS blur layers (2D) |
| Vignette | Radial gradient overlay |
| Chromatic aberration, dithering, halftone | Paper Shaders, `postprocessing` |
| Motion blur feel | Easing and short opacity trails rather than real blur |

## Effects

Effects (shaders, particles, cursor trails, 3D tilts, scroll scenes) must earn their place: one signature effect per surface, tied to the brand idea, with a reduced-motion and low-power fallback. If removing it changes nothing about what the page says, remove it.

## Check

In the self-critique: is the light direction consistent, does every surface have one material, are shadows on the elevation system, is everything graded to the same palette, and is there at most one signature effect?
