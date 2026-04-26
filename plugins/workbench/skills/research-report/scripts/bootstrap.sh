#!/usr/bin/env bash
# Verify Quarto is installed at ~/.local/share/quarto/bin/quarto. Install if missing.
# Idempotent — safe to run on every research invocation.

set -euo pipefail

QUARTO_DIR="$HOME/.local/share/quarto"
QUARTO_BIN="$QUARTO_DIR/bin/quarto"

if [ -x "$QUARTO_BIN" ]; then
  exit 0
fi

echo "Quarto not found. Installing to $QUARTO_DIR..."
mkdir -p "$QUARTO_DIR"

# Detect arch (Apple Silicon vs Intel) — Quarto ships universal macOS builds, so one URL covers both
TMP_TGZ="$(mktemp -t quarto-XXXX.tar.gz)"
trap 'rm -f "$TMP_TGZ"' EXIT

curl -fsSL \
  "https://github.com/quarto-dev/quarto-cli/releases/latest/download/quarto-1.9.37-macos.tar.gz" \
  -o "$TMP_TGZ"

tar -xzf "$TMP_TGZ" -C "$QUARTO_DIR" --strip-components=1

if [ -x "$QUARTO_BIN" ]; then
  echo "Quarto installed: $($QUARTO_BIN --version)"
else
  echo "Quarto install failed — binary not found at $QUARTO_BIN" >&2
  exit 1
fi
