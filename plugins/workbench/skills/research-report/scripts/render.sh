#!/usr/bin/env bash
# Render the report.qmd in .build/ to report.html at the top of the project folder.
# Usage: render.sh <umbrella> <slug> [project-root]

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <umbrella> <slug> [project-root]" >&2
  exit 2
fi

UMBRELLA="$1"
SLUG="$2"
PROJ_ROOT="${3:-}"

if [ -z "$PROJ_ROOT" ]; then
  if PROJ_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then :; else PROJ_ROOT="$(pwd)"; fi
fi

DEST="$PROJ_ROOT/research/$UMBRELLA/$SLUG"
BUILD="$DEST/.build"

if [ ! -f "$BUILD/report.qmd" ]; then
  echo "No report.qmd found at $BUILD/report.qmd. Run new.sh first." >&2
  exit 1
fi

QUARTO_BIN="$HOME/.local/share/quarto/bin/quarto"
if [ ! -x "$QUARTO_BIN" ]; then
  echo "Quarto not installed. Run bootstrap.sh first." >&2
  exit 1
fi

cd "$BUILD"

# Render — Quarto outputs to _output/ by default per _quarto.yml
"$QUARTO_BIN" render report.qmd

# Move/copy the rendered HTML to the top of the topic folder so the user only sees notes.md + report.html
if [ -f "$BUILD/_output/report.html" ]; then
  cp "$BUILD/_output/report.html" "$DEST/report.html"
elif [ -f "$BUILD/report.html" ]; then
  cp "$BUILD/report.html" "$DEST/report.html"
else
  echo "Rendered HTML not found in expected locations." >&2
  exit 1
fi

# Portability check: warn if any non-content external asset deps slipped in.
# embed-resources should inline all CSS/JS/font/image refs. Content links (anchors,
# external doc URLs) are fine. We flag only <link rel="stylesheet" href="http..."> and
# <script src="http..."> which would 404 if the .html is shared without its sidecar.
if grep -qE '<(link[^>]+rel="stylesheet"[^>]+href|script[^>]+src)="https?://' "$DEST/report.html"; then
  echo "" >&2
  echo "  ⚠  Portability warning: report.html references external CSS/JS over http(s)." >&2
  echo "     This means embed-resources may not be set or has been overridden." >&2
  echo "     Sharing this HTML over chat/email will break on the recipient's end." >&2
  echo "     Check templates/_quarto.yml and templates/report.qmd for embed-resources: true" >&2
  echo "" >&2
fi

# Open in default browser
if command -v open >/dev/null 2>&1; then
  open "$DEST/report.html"
fi

echo "$DEST/report.html"
