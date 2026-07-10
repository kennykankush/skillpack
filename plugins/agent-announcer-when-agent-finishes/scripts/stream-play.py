#!/usr/bin/env python3
"""Play announcer audio from stdin AS IT ARRIVES.

The dispatcher streams raw s16le PCM (24 kHz mono) chunk-by-chunk while the voice
is still being generated; this pipes it straight into ffplay so playback starts on
the first chunk. Also accepts a complete WAV (RIFF) for the non-streaming fallback
path. Empty stdin (204 silent / 503 shed) exits without a sound.
"""
import subprocess
import sys

def main() -> int:
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
        # no ffplay: swallow the stream silently rather than erroring the hook
        sys.stdin.buffer.read()
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
