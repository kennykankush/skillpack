#!/usr/bin/env python3
"""Play announcer audio from stdin AS IT ARRIVES.

The dispatcher streams raw s16le PCM (24 kHz mono) chunk-by-chunk while the voice
is still being generated; this pipes it straight into ffplay so playback starts on
the first chunk. Also accepts a complete WAV (RIFF) for the non-streaming fallback
path. Empty stdin (204 silent / 503 shed) exits without a sound.

PLAYBACK LOCK: generation now outruns playback (RTF ~0.4), so back-to-back
announcements (Stop + Notification, or two agents) would otherwise talk over each
other. An exclusive flock on /tmp/tab-tts-play.lock serializes the speakers: wait
up to TAB_TTS_PLAY_WAIT_SEC (default 20s) for the current voice to finish, then
give up silently — a handover that waited that long is stale anyway.
"""
import fcntl
import os
import subprocess
import sys
import time

LOCK_PATH = "/tmp/tab-tts-play.lock"

def _drain() -> None:
    try:
        while sys.stdin.buffer.read(65536):
            pass
    except Exception:
        pass

def main() -> int:
    # Serialize playback FIRST (before consuming the stream, so backpressure holds
    # the chunks upstream). The flock is released automatically when we exit.
    lock = open(LOCK_PATH, "w")
    wait_s = float(os.environ.get("TAB_TTS_PLAY_WAIT_SEC", "20"))
    t0 = time.time()
    while True:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            break
        except OSError:
            if time.time() - t0 > wait_s:
                _drain()                # someone's still talking: skip, stay silent
                return 0
            time.sleep(0.2)

    head = sys.stdin.buffer.read(4)
    if not head:
        return 0                        # nothing to play (coalesced/shed) -> stay silent
    if head == b"RIFF":                 # whole-WAV fallback path
        cmd = ["ffplay", "-hide_banner", "-loglevel", "error",
               "-nodisp", "-autoexit", "-i", "-"]
    else:                               # streamed raw PCM
        cmd = ["ffplay", "-hide_banner", "-loglevel", "error",
               "-nodisp", "-autoexit", "-f", "s16le", "-ar", "24000",
               "-ch_layout", "mono", "-i", "-"]
    try:
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except FileNotFoundError:
        _drain()                        # no ffplay: swallow silently, don't error the hook
        return 0
    assert p.stdin is not None
    try:
        p.stdin.write(head)
        while True:
            buf = sys.stdin.buffer.read(8192)
            if not buf:
                break
            p.stdin.write(buf)
            p.stdin.flush()
    except BrokenPipeError:
        pass
    finally:
        try:
            p.stdin.close()
        except Exception:
            pass
        p.wait()
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
