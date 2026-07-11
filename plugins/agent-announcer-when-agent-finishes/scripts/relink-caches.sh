#!/usr/bin/env bash
# Re-point every Claude/Codex plugin-cache copy of the announcer scripts at this
# repo (dev symlinks = edits are live instantly, no stale snapshots).
#
# WHY: every plugin version bump makes the marketplace create a NEW cache dir
# containing COPIED files — silently reverting the announcer to an old snapshot.
# Run this after any version bump (or whenever announcements behave like an
# older era): bash scripts/relink-caches.sh
set -u
DEV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for d in "$HOME"/.claude/plugins/cache/*/agent-announcer-when-agent-finishes/*/scripts \
         "$HOME"/.codex/plugins/cache/*/agent-announcer-when-agent-finishes/*/scripts; do
  [ -d "$d" ] || continue
  [ "$d" = "$DEV" ] && continue
  for f in announce.sh stream-play.py; do
    ln -sf "$DEV/$f" "$d/$f"
  done
  echo "linked: $d"
done
echo "done — all caches track $DEV"
