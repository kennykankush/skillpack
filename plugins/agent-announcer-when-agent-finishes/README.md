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
4. Speaks `Tab N: <summary>` via `gpt-4o-mini-tts` (or macOS `say` if no key)

A 2-second debounce prevents duplicate announcements when multiple events fire close together.

## Install

### Prereqs
- macOS (uses `osascript` and `afplay`)
- Ghostty terminal (for tab detection — falls back gracefully on others)
- `jq`, `curl` (preinstalled or `brew install jq`)
- An OpenAI API key for TTS (optional — falls back to macOS `say`)
- *Optional:* [Ollama](https://ollama.com) for the summary model if you want local/offline inference

### Set up the API key
```bash
mkdir -p ~/.config/tab-tts && chmod 700 ~/.config/tab-tts
cp <skillpack>/plugins/agent-announcer-when-agent-finishes/env.example ~/.config/tab-tts/env
chmod 600 ~/.config/tab-tts/env
# edit the file and paste your OPENAI_TTS_KEY
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

## Configuration

All env vars are optional. Set them in `~/.config/tab-tts/env`. See `env.example`.

| Var | Default | Notes |
|---|---|---|
| `OPENAI_TTS_KEY` | unset → falls back to `say` | Real api.openai.com key (separate from any proxy-scoped `OPENAI_API_KEY`) |
| `TAB_TTS_MODE` | `summary` | `summary` = LLM handover; `number` = just the tab number |
| `TAB_TTS_VOICE` | `nova` | `nova`, `shimmer`, `sage`, `coral`, `alloy`, `ash`, `ballad`, `echo`, `fable`, `onyx`, `verse` |
| `TAB_TTS_INSTRUCTIONS` | warm/playful default | Natural-language voice direction (gpt-4o-mini-tts only) |
| `TAB_TTS_MODEL` | `gpt-4o-mini-tts` | TTS model (the *speaking* model) |
| `TAB_TTS_SUMMARY_MODEL` | `gpt-4.1-nano` | Chat model for the handover summary |
| `TAB_TTS_SUMMARY_BASE_URL` | `https://api.openai.com/v1` | Override to point at Ollama, vLLM, DeepSeek, Together, Groq, etc. |
| `TAB_TTS_SUMMARY_KEY` | falls back to `OPENAI_TTS_KEY` | Separate key for the summary endpoint if different from TTS |
| `TAB_TTS_DEBOUNCE_SEC` | `2` | Suppress repeat fires within this window |

## Cost

Per fire (summary mode, OpenAI cloud route):
- Chat completion (~200 input + 30 output tokens, `gpt-4.1-nano`) ≈ **$0.00016**
- TTS (~50 chars, `gpt-4o-mini-tts`) ≈ **$0.00003**
- Total ≈ **$0.0002 per turn** → roughly **$0.20 per 1,000 turns**

Local Ollama route: **$0** for the summary; TTS still hits OpenAI unless you also disable that.

Set `TAB_TTS_MODE=number` to skip the chat call entirely if you only want the tab number spoken.

## Diagnostics

Append-only log at `/tmp/tab-tts.log`. Each fire writes invoker, tab detection result, summary text, summary endpoint used, and TTS HTTP status. To debug, tail it while triggering an event:

```bash
tail -f /tmp/tab-tts.log
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
        b. POST api.openai.com/v1/audio/speech       → mp3 with voice instructions
        c. afplay                                    → speak
```

The parent script returns instantly; the network/local-LLM calls and playback happen in a detached subshell so the agent never blocks on the hook.

## License

MIT.
