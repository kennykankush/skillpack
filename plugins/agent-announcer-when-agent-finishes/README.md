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
3. Asks `gpt-4o-mini` for a one-sentence handover summary
4. Speaks `Tab N: <summary>` via `gpt-4o-mini-tts` (or macOS `say` if no key)

A 2-second debounce prevents duplicate announcements when multiple events fire close together.

## Install

### Prereqs
- macOS (uses `osascript` and `afplay`)
- Ghostty terminal (for tab detection — falls back gracefully on others)
- `jq`, `curl` (preinstalled or `brew install jq`)
- An OpenAI API key with access to `gpt-4o-mini` and `gpt-4o-mini-tts` (optional — falls back to `say`)

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

## Configuration

All env vars are optional. Set them in `~/.config/tab-tts/env`. See `env.example`.

| Var | Default | Notes |
|---|---|---|
| `OPENAI_TTS_KEY` | unset → falls back to `say` | Real api.openai.com key (separate from any proxy-scoped `OPENAI_API_KEY`) |
| `TAB_TTS_MODE` | `summary` | `summary` = LLM handover; `number` = just the tab number |
| `TAB_TTS_VOICE` | `nova` | `nova`, `shimmer`, `sage`, `coral`, `alloy`, `ash`, `ballad`, `echo`, `fable`, `onyx`, `verse` |
| `TAB_TTS_INSTRUCTIONS` | warm/playful default | Natural-language voice direction (gpt-4o-mini-tts only) |
| `TAB_TTS_MODEL` | `gpt-4o-mini-tts` | TTS model |
| `TAB_TTS_SUMMARY_MODEL` | `gpt-4o-mini` | Chat model for the handover summary |
| `TAB_TTS_DEBOUNCE_SEC` | `2` | Suppress repeat fires within this window |

## Cost

Per fire (summary mode):
- Chat completion (~200 input + 30 output tokens) ≈ **$0.0001**
- TTS (~50 chars) ≈ **$0.00003**
- Total ≈ **$0.0002 per turn** → roughly **$0.20 per 1000 turns**

Set `TAB_TTS_MODE=number` to skip the chat call entirely if you only want the tab number spoken.

## Diagnostics

Append-only log at `/tmp/tab-tts.log`. Each fire writes invoker, tab detection result, summary text, and TTS HTTP status. To debug, tail it while triggering an event:

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
        a. POST /v1/chat/completions   → one-sentence summary
        b. POST /v1/audio/speech       → mp3 with custom voice instructions
        c. afplay                       → speak
```

The parent script returns instantly; the network calls and playback happen in a detached subshell so the agent never blocks on the hook.

## License

MIT.
