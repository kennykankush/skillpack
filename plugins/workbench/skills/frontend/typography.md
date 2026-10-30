# Typography

Type carries most of what reads as "designed". Weak defaults (system stack, Inter at every size, one weight) are the fastest route to generic. Choose type from what the references actually use, then set it with care.

## Finding the right face

- **Read it off the references.** On each top reference, read the computed `font-family`, weights, sizes, line heights and letter spacing with `chrome-devtools`. Name what they use before choosing.
- **In-use galleries**: Typewolf and Fonts In Use show faces in real products and sites, by mood and category.
- **MCP and skill help**: `madegood` (typography and brand references), `ui-ux-pro-max` (font pairings by product type), Google Design MCP (`search_fonts`, `describe_font`; needs Google Cloud setup).

## Sources

| Source | Licence | Notes |
|---|---|---|
| Google Fonts / Fontsource | Free (OFL mostly) | Self-host through `@fontsource-variable/*` |
| Fontshare (Indian Type Foundry) | Free for commercial use | Satoshi, General Sans, Cabinet Grotesk, Clash Display: strong modern sans and display faces |
| Geist (`geist`, `@fontsource-variable/geist`) | Free (OFL) | Clean sans and mono |
| Velvetyne, Collletttivo, uncut.wtf | Free / open | Expressive display faces for editorial and art direction |
| Pangram Pangram, Klim, Grilli Type, Displaay, Dinamo, Commercial Type | Paid | Only when the user licenses them; Pangram Pangram has free trial licences for personal use |

Always check the licence covers web embedding and the product's use.

## Pairing rules

- One family with a real weight range often beats two. If pairing, contrast clearly (serif display with sans text, or grotesk with mono accents), never two similar sans.
- A display face for headlines, a workhorse for UI and body, an optional mono for data and code.
- Use the variable version where it exists; pick weights deliberately (for example 400 / 500 / 650), not every weight.

## Setting it well

- **Scale**: a modular scale with a clear jump between levels. Fluid sizes with `clamp()` (generate with utopia.fyi).
- **Line height and tracking**: tighter leading and slight negative tracking on large display sizes; looser on small text. Uppercase labels get positive tracking.
- **Trim the box**: `text-box: trim-both cap alphabetic` where supported, or `@capsizecss/core` to remove the extra space above and below text so spacing and alignment are exact.
- **Wrapping**: `text-wrap: balance` for headings, `text-wrap: pretty` for paragraphs.
- **Numbers**: `font-variant-numeric: tabular-nums` in tables, prices and anything that updates; consider slashed zero for data.
- **Optical sizing and features**: enable `font-optical-sizing` and the face's stylistic sets where they help.
- **Loading**: self-host, preload the one or two critical files, `font-display: swap`, and size-matched fallbacks (`fontaine` or capsize metrics) so the swap causes no layout shift.

## Check

In the self-critique, confirm the chosen faces actually render (not a fallback), the hierarchy reads at a glance, and nothing uses a weight or size outside the scale.
