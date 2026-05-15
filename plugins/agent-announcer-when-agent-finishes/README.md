# agent-announcer-when-agent-finishes

Speaks a one-line contextual handover when Claude Code or Codex finishes a turn or needs input. Prefixed with your Ghostty tab number so you know which agent is talking.

> *"Tab 3: I pulled the nutrition info on those three pizzas."*

## What it does

Fires on:
- **Claude Code** `Stop` (turn complete) and `Notification` (needs input/permission)
- **Codex CLI** `Stop` (turn complete) and `PermissionRequest` (needs approval)

For each fire:
1. Detects which Ghostty tab the agent is running in (AppleScript cwd-match + OSC title-marker fallback)
2. Reads the agent's last response (Claude transcript JSONL or Codex `last_assistant_message` payload)
3. Asks a chat model for a one-sentence handover summary (defaults to OpenAI `gpt-4.1-nano`; can route to **local Ollama** or any OpenAI-compatible endpoint)
4. Speaks `Tab N: <summary>` via local Qwen, ElevenLabs, OpenAI TTS, or macOS `say`

A 2-second debounce prevents duplicate announcements when multiple events fire close together.

## Install

### Prereqs
- macOS (uses `osascript` and `afplay`)
- Ghostty terminal (for tab detection — falls back gracefully on others)
- `jq`, `curl` (preinstalled or `brew install jq`)
- A local Qwen voicepack or an ElevenLabs/OpenAI API key for TTS (optional — falls back to macOS `say`)
- *Optional:* [Ollama](https://ollama.com) for the summary model if you want local/offline inference

### Set up the API key
```bash
mkdir -p ~/.config/tab-tts && chmod 700 ~/.config/tab-tts
cp <skillpack>/plugins/agent-announcer-when-agent-finishes/env.example ~/.config/tab-tts/env
chmod 600 ~/.config/tab-tts/env
# edit the file and paste your ELEVENLABS_API_KEY and/or OPENAI_TTS_KEY
```

### Claude Code
```
/plugin marketplace add github.com/kennykankush/skillpack
/plugin install agent-announcer-when-agent-finishes@kennykankush-skillpack
/reload-plugins
```

After reload, the hook fires automatically. You can also see it via `/plugin list`.

### Codex CLI
Codex picks up plugin hooks too, but if you're already on an older version, drop this into your `~/.codex/config.toml` once:

```toml
[features]
hooks = true

[[hooks.Stop]]

[[hooks.Stop.hooks]]
type = "command"
command = "bash ~/.claude/plugins/cache/kennykankush-skillpack/agent-announcer-when-agent-finishes/<version>/scripts/announce.sh codex"
timeout = 15

[[hooks.PermissionRequest]]

[[hooks.PermissionRequest.hooks]]
type = "command"
command = "bash ~/.claude/plugins/cache/kennykankush-skillpack/agent-announcer-when-agent-finishes/<version>/scripts/announce.sh codex-permission"
timeout = 15
```

Replace `<version>` with the installed version (check via `ls ~/.claude/plugins/cache/kennykankush-skillpack/agent-announcer-when-agent-finishes/`).

## Summary model: OpenAI vs local Ollama

The summary step is OpenAI-compatible, so you can route it to any backend that speaks the Chat Completions API. Two recommended setups:

### Option A — OpenAI cloud (default)

Set `OPENAI_TTS_KEY` in your env file and leave `TAB_TTS_SUMMARY_BASE_URL` unset. Defaults to `https://api.openai.com/v1` with `gpt-4.1-nano`. Costs ~$0.16 per 1,000 announcements. Zero local resource footprint.

### Option B — Local Ollama with **qwen2.5:7b** (recommended for privacy / offline)

1. Install and start Ollama:
   ```bash
   brew install ollama
   brew services start ollama
   ollama pull qwen2.5:7b      # ~4.4 GB
   ```

2. Add to `~/.config/tab-tts/env`:
   ```
   TAB_TTS_SUMMARY_BASE_URL=http://localhost:11434/v1
   TAB_TTS_SUMMARY_MODEL=qwen2.5:7b
   ```

3. (Optional) shorten Ollama's keep-alive so the model unloads quickly when idle:
   ```bash
   export OLLAMA_KEEP_ALIVE=30s
   ```

Inference clocks in around **600 ms warm** on an M-series Mac. The model loads on demand and unloads after the keep-alive window, so when idle it costs ~0 % CPU and ~50 MB RAM (just the Ollama daemon). The script auto-detects `localhost` and skips the `Authorization` header.

**Other model picks** (drop-in replacements for `TAB_TTS_SUMMARY_MODEL`):

| Model | Size | Warm latency | Notes |
|---|---:|---:|---|
| `qwen2.5:7b` ⭐ | 4.4 GB | ~600 ms | Best wording, recommended |
| `llama3.2:3b` | 1.9 GB | ~500 ms | 90 % as good, half the RAM |
| `qwen2.5:1.5b` | 1.0 GB | ~250 ms | Floor for reliable instruction-following |
| `gemma3:1b` | 815 MB | ~200 ms | Tiny, decent |

Avoid reasoning models (`gpt-5-nano`, `deepseek-r1`, `qwq`) — they burn tokens *thinking* before producing the one-line summary, which is the wrong tool for this task.

## Voice provider: Qwen vs ElevenLabs vs OpenAI vs macOS say

The speaking step is configurable separately from the summary step.

Use the local Qwen voicepack first, then fall back automatically:

```bash
TAB_TTS_PROVIDER=qwen
TAB_TTS_FALLBACK_PROVIDER=openai
TAB_TTS_QWEN_PYTHON="$HOME/dev/voicepack/.venv-qwen/bin/python"
TAB_TTS_QWEN_RUNNER="$HOME/dev/voicepack/runners/qwen/speak.py"
TAB_TTS_QWEN_VOICE="$HOME/dev/voicepack/library/cortana"
```

The Qwen provider expects `TAB_TTS_QWEN_VOICE/voice.pt` to exist.
That file behaves like the local voice id: the announcer passes only the handover
text, and the Qwen runner renders a fresh audio file from the saved voice prompt.

For lower latency, the hook can manage a warm localhost Qwen server itself.
This is enabled by default for `TAB_TTS_PROVIDER=qwen`: the first hook after
reboot checks `http://127.0.0.1:8765`, starts the server if missing, waits for it
to become healthy, and then speaks through it. Later hooks reuse the warm server.

```bash
TAB_TTS_QWEN_AUTO_SERVER=1
```

The first cold hook still pays the Qwen model-load cost. If the warm server
cannot start, the hook falls back to one-shot `speak.py`.

Use ElevenLabs first, then fall back automatically:

```bash
TAB_TTS_PROVIDER=elevenlabs
TAB_TTS_FALLBACK_PROVIDER=openai
ELEVENLABS_API_KEY=...
OPENAI_TTS_KEY=sk-proj-...
```

Or use the shorter alias:

```bash
VOICE_CHANNEL=elevenlabs
```

`TAB_TTS_PROVIDER=auto` tries ElevenLabs when `ELEVENLABS_API_KEY` is set, then OpenAI when `OPENAI_TTS_KEY` is set, then macOS `say`. Set `TAB_TTS_PROVIDER=qwen` explicitly to use the local Qwen voicepack. ElevenLabs usage is checked through `/v1/user/subscription` before a speech request; if remaining credits are below `phrase length + ELEVENLABS_MIN_REMAINING_CREDITS`, the script skips ElevenLabs and falls through to the next provider.

Summary length is budget-aware. With `TAB_TTS_SUMMARY_BUDGET=auto`, local Qwen
TTS gets a richer handover, while paid OpenAI/ElevenLabs TTS gets a compact
handover. Use `TAB_TTS_SUMMARY_BUDGET=tab` when you want the cheapest behavior:
only the tab label is spoken.

### ElevenLabs voice presets

Set `ELEVENLABS_VOICE_ID` to whichever voice should speak the announcement:

| Voice ID | Description |
|---|---|
| `hpp4J3VqNfWAUOO0d1Us` | Bella, a bright/professional premade female voice |
| `sJSpUxhUVjGSYgbo5FeK` | User-generated Cortana/Halo-inspired sci-fi AI companion voice |

The Cortana-style ID is not an official Halo/Microsoft/Jen Taylor voice and may only work for accounts where that generated voice is saved. If ElevenLabs returns `voice_not_found`, create or save a similar voice in your own account and replace the ID.

## Configuration

All env vars are optional. Set them in `~/.config/tab-tts/env`. See `env.example`.

| Var | Default | Notes |
|---|---|---|
| `TAB_TTS_PROVIDER` | `auto` | `auto`, `qwen`, `elevenlabs`, `openai`, or `say` |
| `TAB_TTS_VOICE_CHANNEL` / `VOICE_CHANNEL` | unset | Alias for `TAB_TTS_PROVIDER`; useful if you prefer `VOICE_CHANNEL=elevenlabs` |
| `TAB_TTS_FALLBACK_PROVIDER` | `auto` | Provider to try after the selected provider fails or is low on credits |
| `TAB_TTS_QWEN_PYTHON` | `~/dev/voicepack/.venv-qwen/bin/python` | Python executable with `qwen_tts` installed |
| `TAB_TTS_QWEN_RUNNER` | `~/dev/voicepack/runners/qwen/speak.py` | Runner that speaks through a saved Qwen prompt file |
| `TAB_TTS_QWEN_VOICE` | `~/dev/voicepack/library/cortana` | Voice ID directory containing `voice.pt` |
| `TAB_TTS_QWEN_AUTO_SERVER` | `1` | Start and reuse the warm local Qwen server automatically |
| `TAB_TTS_QWEN_SERVER_URL` | `http://127.0.0.1:8765` when auto server is on | Warm Qwen server URL |
| `TAB_TTS_QWEN_AUTO_START_TIMEOUT_SEC` | `60` | Max seconds to wait for first cold server startup |
| `TAB_TTS_QWEN_SERVER_TIMEOUT_SEC` | `30` | Max seconds to wait for a warm server render before falling back to `speak.py` |
| `TAB_TTS_QWEN_DEVICE` | unset | Optional Qwen device override, for example `mps` |
| `TAB_TTS_QWEN_DTYPE` | unset | Optional Qwen dtype override, for example `float16` |
| `TAB_TTS_QWEN_SEED` | unset | Optional Qwen generation seed override |
| `ELEVENLABS_API_KEY` | unset | ElevenLabs key for text-to-speech |
| `ELEVENLABS_VOICE_ID` | `JBFqnCBsd6RMkjVDRZzb` | ElevenLabs voice id |
| `ELEVENLABS_MODEL_ID` | `eleven_flash_v2_5` | ElevenLabs TTS model |
| `ELEVENLABS_OUTPUT_FORMAT` | `mp3_44100_128` | ElevenLabs audio format |
| `ELEVENLABS_CHECK_CREDITS` | `1` | Check subscription usage before spending credits |
| `ELEVENLABS_MIN_REMAINING_CREDITS` | `200` | Reserve credits before falling back |
| `OPENAI_TTS_KEY` | unset | Real api.openai.com key for OpenAI TTS |
| `TAB_TTS_MODE` | `summary` | `summary` = LLM handover; `number` = just the tab label |
| `TAB_TTS_VOICE` | `nova` | `nova`, `shimmer`, `sage`, `coral`, `alloy`, `ash`, `ballad`, `echo`, `fable`, `onyx`, `verse` |
| `TAB_TTS_INSTRUCTIONS` | warm/playful default | Natural-language voice direction (gpt-4o-mini-tts only) |
| `TAB_TTS_MODEL` | `gpt-4o-mini-tts` | TTS model (the *speaking* model) |
| `TAB_TTS_SUMMARY_MODEL` | `gpt-4.1-nano` | Chat model for the handover summary |
| `TAB_TTS_SUMMARY_BASE_URL` | `https://api.openai.com/v1` | Override to point at Ollama, vLLM, DeepSeek, Together, Groq, etc. |
| `TAB_TTS_SUMMARY_KEY` | falls back to `OPENAI_TTS_KEY` | Separate key for the summary endpoint if different from TTS |
| `TAB_TTS_SUMMARY_BUDGET` | `auto` | `auto`, `local`, `paid`, or `tab` |
| `TAB_TTS_LOCAL_SUMMARY_WORDS` | `12-24 words` | Target word range for local TTS summaries |
| `TAB_TTS_LOCAL_SUMMARY_MAX_CHARS` | `220` | Max spoken summary chars for local TTS |
| `TAB_TTS_LOCAL_SUMMARY_MAX_TOKENS` | `140` | Max summary-model output tokens for local TTS |
| `TAB_TTS_PAID_SUMMARY_WORDS` | `6-10 words` | Target word range for paid TTS summaries |
| `TAB_TTS_PAID_SUMMARY_MAX_CHARS` | `90` | Max spoken summary chars for paid TTS |
| `TAB_TTS_PAID_SUMMARY_MAX_TOKENS` | `60` | Max summary-model output tokens for paid TTS |
| `TAB_TTS_DEBUG` | `0` | Set to `1`/`on`/`true` to log `[model] } tab } source } spoken text }` before playback |
| `TAB_TTS_DEBUG_SPEAK` | `0` | Set to `1`/`on`/`true` to speak the debug prefix too |
| `TAB_TTS_TIMING` | `1` | Write JSONL benchmark records for every completed provider attempt |
| `TAB_TTS_TIMING_LOG` | `/tmp/tab-tts-timings.jsonl` | Machine-readable timing dataset path |
| `TAB_TTS_DEBOUNCE_SEC` | `2` | Suppress repeat fires within this window |

## Cost

Per fire (summary mode, OpenAI cloud route):
- Chat completion (~200 input + 30 output tokens, `gpt-4.1-nano`) ≈ **$0.00016**
- TTS (~50 chars, `gpt-4o-mini-tts`) ≈ **$0.00003**
- Total ≈ **$0.0002 per turn** → roughly **$0.20 per 1,000 turns**

Local Ollama route: **$0** for the summary; TTS still uses whichever voice provider you select.

Set `TAB_TTS_MODE=number` to skip the chat call entirely if you only want the tab label spoken.

## Diagnostics

Append-only log at `/tmp/tab-tts.log`. Each fire writes invoker, tab detection result, summary text, summary endpoint used, and TTS status.

Timing records are also written to `/tmp/tab-tts-timings.jsonl` by default. Each
record includes hook sync time, summary time, TTS generation time, time from hook
start to audio-ready, and full playback completion time.

Set `TAB_TTS_DEBUG=1` to add a compact line before playback:

```text
tts_debug=[Qwen/Qwen3-TTS-12Hz-1.7B-Base] } 3 } /Users/hamulia/dev/voicepack/library/cortana } Tab 3: I updated the announcer provider. }
```

Set `TAB_TTS_DEBUG_SPEAK=1` if you want the spoken audio itself to begin with
the same model/tab prefix.

To debug, tail the log while triggering an event:

```bash
tail -f /tmp/tab-tts.log
```

Summarize the timing dataset:

```bash
python3 <skillpack>/plugins/agent-announcer-when-agent-finishes/scripts/analyze-timings.py
```

Estimate older runs from the human log too:

```bash
python3 <skillpack>/plugins/agent-announcer-when-agent-finishes/scripts/analyze-timings.py --legacy-log
```

## Architecture

```
agent event (Stop/Notification/PermissionRequest)
        │
        ▼
hooks/hooks.json  (Claude Code)  or  ~/.codex/config.toml  (Codex)
        │
        ▼
scripts/announce.sh <invoker>      ← sources ~/.config/tab-tts/env
   1. Debounce (2s window)
   2. Read stdin JSON payload
   3. Walk process tree → parent tty
   4. AppleScript Ghostty → tab number
   5. Extract last assistant message (transcript JSONL or payload field)
   6. fork → background:
        a. POST $SUMMARY_BASE_URL/chat/completions   → one-sentence summary
           (OpenAI, Ollama, DeepSeek, Groq, etc.)
        b. POST selected TTS provider                → mp3 audio
        c. afplay                                    → speak
```

The parent script returns instantly; the network/local-LLM calls and playback happen in a detached subshell so the agent never blocks on the hook.

## License

MIT.
