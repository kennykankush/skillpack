# Design packages

The packages that make an interface look and feel finished. These are installed per project, never globally; pick by what the chosen direction needs and what the project's framework already is. Fetch current docs through `context7` before using one, since APIs move fast. Prefer framework-agnostic packages unless the project is already committed to one.

## Visual richness

| Package | Use it for | Notes |
|---|---|---|
| `@paper-design/shaders` / `@paper-design/shaders-react` | Mesh gradients, grain, dithering, liquid metal, warped backgrounds | GPU shaders that replace flat gradients and stock blobs. Best single upgrade for "the background is underwhelming". Pre-1.0: pin the version |
| `three` / `@react-three/fiber` + `@react-three/drei` | Real 3D scenes, product objects | Heavy; only when 3D is the point |
| `@rive-app/canvas` / `@rive-app/react-canvas` | Interactive vector animation with state machines | Mascots, rich icons, onboarding illustrations that react to input |
| `@lottiefiles/dotlottie-web` / `-react` | Playback of designed vector animations | When a designer or LottieFiles asset exists |
| `@shadergradient/react` | Animated 3D gradient backgrounds | Quick premium hero backgrounds; lighter alternative to custom shaders |
| `ogl` | Minimal WebGL for custom shaders | Much smaller than three; for one bespoke effect |
| `unicornstudio-react` | Embeds WebGL scenes designed in Unicorn Studio (no-code) | Design the effect visually, ship it as an embed |
| `postprocessing` / `@react-three/postprocessing` | Bloom, grain, depth of field, chromatic effects on 3D | Only with three / R3F |
| `cobe` | Lightweight interactive globe | The "global" hero without full three |

## Motion

| Package | Use it for | Notes |
|---|---|---|
| `motion` (formerly Framer Motion) | UI transitions, layout animation, gestures, springs | Default for React; also has a vanilla JS API |
| `gsap` (+ ScrollTrigger, SplitText, Flip) | Timelines, scroll choreography, text effects | Free including plugins; framework-agnostic. Use the `gsap-*` skills |
| `lenis` | Smooth scrolling | Pairs with GSAP ScrollTrigger on marketing pages; skip in apps |
| `@number-flow/react` (also vanilla, Vue, Svelte) | Animated number changes | Balances, prices, counters: makes data feel alive |
| `animejs` (v4) | Lightweight timelines for DOM, SVG, CSS | Framework-agnostic; smaller than GSAP |
| `@react-spring/web` + `@use-gesture/react` | Physics motion and drag, pinch, scroll gestures | Draggable cards, sheets, tactile UI |
| `@formkit/auto-animate` | One-line enter, exit and reorder transitions | Lists, tables, any framework |
| `@theatre/core` | Visual timeline editor for choreographed sequences | Hero sequences tuned by eye |
| `split-type` | Split text into lines, words, characters | Text reveals with GSAP or Motion |
| `motion-plus` | Paid Motion extras (ticker, typewriter, cursor, carousel) | Only with a Motion+ licence |

## Interaction primitives (unstyled, so the look stays yours)

| Package | Use it for | Notes |
|---|---|---|
| `@radix-ui/*` | Dialogs, menus, popovers, tabs, tooltips with correct accessibility | Unstyled, React |
| `@base-ui-components/react` | Same space, from the Radix and MUI authors | Newer; check stability |
| `sonner` | Toasts | Polished default motion |
| `vaul` | Drawers, mobile bottom sheets | |
| `cmdk` | Command palette | |
| `embla-carousel` / `embla-carousel-react` | Carousels with correct touch physics | |
| `@tsparticles/react` | Particle fields | Use sparingly; easy to make it look cheap |

Copy-paste component galleries (React Bits, shadcn/ui, Magic UI, Aceternity, 21st.dev) are sources to study and adapt, not dependencies. They assume React and Tailwind; restyle to the chosen system rather than shipping their default look.

## Type and icons

| Package | Use it for | Notes |
|---|---|---|
| `@fontsource-variable/*` | Self-hosted variable fonts (Inter, Geist, Manrope, etc.) | No Google Fonts request; any framework |
| `geist` | Vercel's Geist Sans and Mono | |
| `@phosphor-icons/*` | Icons with several weights | Weights help match type weight |
| `lucide` / `lucide-react` | Clean line icons | The common default; restyle stroke width to match the type |
| `@iconify/*` | 200k+ icons from 150+ sets through one API | Search with the `better-icons` MCP, then pin one set per product |
| `@hugeicons/react`, `@tabler/icons-react` | Large consistent icon sets | Alternatives when Lucide feels generic |
| `react-wrap-balancer` | Balanced headline wrapping | CSS `text-wrap: balance` / `pretty` now covers most cases |

Font choice comes from the references, not this list. Free foundry options worth checking: Fontshare, Google Fonts, the Geist and Inter families. Paid ones (Klim, Grilli Type, Pangram Pangram) only when the user licenses them.

## Colour

| Package | Use it for | Notes |
|---|---|---|
| `culori` | Build palettes and ramps in OKLCH, check contrast | Even, perceptual ramps instead of hand-picked hex |

## Data display

| Package | Use it for | Notes |
|---|---|---|
| `@visx/*` | Custom charts with full visual control | Low level, React |
| `recharts` | Standard charts quickly | Restyle defaults; load the `dataviz` skill for colour and form |

## Picking

- Match the chosen direction: a dense operator dashboard needs primitives, numbers and charts; a persuasive landing page needs shaders, type and scroll motion.
- One library per job. Do not ship Motion and GSAP for the same effect.
- Check the weight and respect `prefers-reduced-motion` for anything that moves.
