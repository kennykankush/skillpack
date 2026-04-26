#!/usr/bin/env bash
# Scaffold a new research project.
# Usage: new.sh <umbrella> <slug> [project-root]
# - <umbrella>   : marketing | uiux | engineering | product | design | ml | ops | legal | competitive | research-meta
# - <slug>       : kebab-case title (e.g. "replaydeck-reddit-positioning")
# - <project-root> (optional) : defaults to git root or PWD

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Template directory missing: $TEMPLATE_DIR" >&2
  exit 1
fi

DEST="$PROJ_ROOT/research/$UMBRELLA/$SLUG"
BUILD="$DEST/.build"

mkdir -p "$BUILD"

# Copy templates into .build/ (qmd source lives hidden)
cp "$TEMPLATE_DIR/_quarto.yml" "$BUILD/_quarto.yml"
cp "$TEMPLATE_DIR/styles.scss" "$BUILD/styles.scss"
cp "$TEMPLATE_DIR/report.qmd" "$BUILD/report.qmd"

# Stub notes.md at the top level (empty raw-data file the skill fills in)
NOTES="$DEST/notes.md"
if [ ! -f "$NOTES" ]; then
  TODAY="$(date +%Y-%m-%d)"
  cat > "$NOTES" <<EOF
# Research notes — $SLUG

> Raw data dump. Source for the polished report. Skill writes findings here, then synthesizes report.qmd from it.

**Date:** $TODAY
**Umbrella:** $UMBRELLA
**Sources covered:** TBD

---

EOF
fi

# Add /research to .gitignore if in a git repo and not already present
if git -C "$PROJ_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GITIGNORE="$PROJ_ROOT/.gitignore"
  if [ -f "$GITIGNORE" ]; then
    if ! grep -qE '^/research(\b|/)' "$GITIGNORE" 2>/dev/null; then
      printf '\n# Local research notes\n/research\n' >> "$GITIGNORE"
    fi
  else
    printf '# Local research notes\n/research\n' > "$GITIGNORE"
  fi
fi

echo "$DEST"
