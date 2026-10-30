# Assets and graphics

Material fetching: the imagery, illustration, icons, 3D, motion files and backgrounds that make a surface feel finished. Empty heroes, stock blobs, hand-drawn SVG icons and lorem pictures read as amateur faster than any layout flaw. Decide the asset language in the system step (one illustration style, one icon set, one photo treatment) and fetch real material before the build, not after.

Check licences every time: record the source and licence of each asset in `.design/ASSETS.md`, and add attribution where the licence asks for it.

## Icons

| Source | Notes |
|---|---|
| `better-icons` MCP / skill | Search 200k+ icons across 150+ Iconify sets and pull the SVG. Default route |
| Phosphor, Lucide, Hugeicons, Tabler, Material Symbols | Pick one set per product; match stroke width to the type weight |

Never hand-draw an icon that a set already has.

## Photography

| Source | Notes |
|---|---|
| Unsplash, Pexels | Free licences. Unsplash requires its API attribution and download tracking when used through the API |
| Unsplash MCP (for example `@hanoak/unsplash-mcp-server`) | Needs a free Unsplash API key; add when a project leans on photography |
| Treatment | Grade photos to the palette (duotone, grain, consistent crop) so they belong to the system |

## Illustration

| Source | Notes |
|---|---|
| unDraw, Storyset, Open Peeps, Humaaans | Free, recolourable to the palette. Common; restyle so they do not read as stock |
| Recraft (MCP: `recraft-ai/mcp-recraft-server`) | Paid API key. Generates consistent vector illustration and icon styles; good for a custom set |
| Image generation (Codex imagegen, Claude-adjacent generators) | Hero art, logo exploration, textures. Generate several, pick, then vectorise or clean up |
| `impeccable-asset-producer` agent | Turns an approved comp's references into clean reusable raster assets |

## 3D

| Source | Notes |
|---|---|
| Spline | Design 3D scenes visually, export as a web embed or React component |
| 3dicons, Poly Haven (models, HDRIs, textures, CC0) | Free 3D material |
| three / R3F (see libraries.md) | When the 3D is code-driven |

## Motion files

| Source | Notes |
|---|---|
| LottieFiles | Free and paid Lottie and dotLottie animations; recolour to the palette |
| Rive community | Interactive animations with state machines |

## Backgrounds, textures and generators

| Source | Notes |
|---|---|
| Paper Shaders, ShaderGradient (libraries.md) | Live GPU backgrounds |
| Haikei | SVG blobs, waves, layered peaks, gradients |
| fffuel | SVG noise, grain, gradients, patterns |
| Grainy gradients (CSS + SVG noise) | Cheap, light, on-trend depth |

## Product imagery

Real product screenshots in device or browser frames beat illustrations for tools and apps. Capture the real UI with Playwright, frame it (Shots.so, or a simple CSS browser frame), and keep the frame style consistent across the site.

## Logos and brand marks

Explore with image generation or Recraft, pick a direction with the user, then produce a clean SVG. Never ship a raster logo as the final mark.
