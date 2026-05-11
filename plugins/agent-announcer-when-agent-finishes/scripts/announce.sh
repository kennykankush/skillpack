#!/usr/bin/env bash
# Announces via TTS which Ghostty tab a Claude/Codex agent finished in,
# plus a one-sentence handover summary generated from the agent's actual output.
#
# Invoked from Claude Code Stop/Notification hooks and Codex CLI Stop hook.
#
# Usage:
#   bash tab-tts.sh claude-stop          # Claude Code Stop event
#   bash tab-tts.sh claude-notification  # Claude Code Notification event
#   bash tab-tts.sh codex                # Codex CLI Stop event
#   bash tab-tts.sh codex-permission     # Codex CLI PermissionRequest event
#
# Env (read from ~/.config/tab-tts/env if present):
#   OPENAI_TTS_KEY          Real api.openai.com key. Falls back to `say` if unset.
#   TAB_TTS_MODE            "summary" (default) or "number"
#   TAB_TTS_VOICE           OpenAI TTS voice (default: nova)
#   TAB_TTS_MODEL           OpenAI TTS model (default: gpt-4o-mini-tts)
#   TAB_TTS_INSTRUCTIONS    Voice styling for gpt-4o-mini-tts
#   TAB_TTS_SUMMARY_MODEL   Chat model for summary (default: gpt-4o-mini)
#   TAB_TTS_DEBOUNCE_SEC    Cross-event debounce window (default: 2)
#
# Log: /tmp/tab-tts.log

INVOKER="${1:-claude-stop}"
LOG=/tmp/tab-tts.log
ENV_FILE="$HOME/.config/tab-tts/env"
[ -r "$ENV_FILE" ] && set -a && . "$ENV_FILE" && set +a

MODE="${TAB_TTS_MODE:-summary}"

# ---- debounce ----
DEBOUNCE_SEC="${TAB_TTS_DEBOUNCE_SEC:-2}"
LOCK="/tmp/tab-tts-lastfire"
NOW=$(date +%s)
LAST=0
[ -f "$LOCK" ] && LAST=$(cat "$LOCK" 2>/dev/null) && [ -z "$LAST" ] && LAST=0
if [ "$((NOW - LAST))" -lt "$DEBOUNCE_SEC" ]; then
  echo "[$(date)] debounced (gap=$((NOW - LAST))s, invoker=$INVOKER)" >> "$LOG"
  exit 0
fi
echo "$NOW" > "$LOCK"

# ---- capture stdin payload synchronously (closes when parent exits) ----
STDIN_JSON=""
if [ ! -t 0 ]; then
  STDIN_JSON=$(cat)
fi

echo "[$(date)] invoker=$INVOKER pwd=$PWD term=${TERM_PROGRAM:-} mode=$MODE stdin_len=${#STDIN_JSON}" >> "$LOG"

# ---- find parent tty SYNC (subshell loses parent chain) ----
TTY=""
_pid=$$
for _ in 1 2 3 4 5 6 7 8 9 10; do
  read -r _pp _tt <<<"$(ps -o ppid=,tty= -p "$_pid" 2>/dev/null)"
  if [ -n "$_tt" ] && [ "$_tt" != "??" ] && [ "$_tt" != "?" ]; then
    TTY="/dev/$_tt"
    break
  fi
  [ -z "$_pp" ] && break
  [ "$_pp" = "1" ] && break
  _pid="$_pp"
done

# ---- detect tab SYNC (~500ms worst case) ----
TAB=""
if [ "${TERM_PROGRAM:-}" = "ghostty" ]; then
  TAB=$(osascript 2>>"$LOG" <<APPLESCRIPT
on run
  set targetCwd to "$PWD"
  set AppleScript's text item delimiters to "/"
  set cwdBase to last text item of targetCwd
  set AppleScript's text item delimiters to ""
  set allMatches to {}
  set agentMatches to {}
  tell application "Ghostty"
    repeat with w in windows
      repeat with t in tabs of w
        repeat with s in terminals of t
          if (working directory of s) is targetCwd then
            set tIdx to (index of t)
            set end of allMatches to tIdx
            if (name of s) is not cwdBase then
              set end of agentMatches to tIdx
            end if
          end if
        end repeat
      end repeat
    end repeat
  end tell
  if (count of agentMatches) is 1 then
    return (item 1 of agentMatches) as text
  else if (count of allMatches) is 1 then
    return (item 1 of allMatches) as text
  end if
  return ""
end run
APPLESCRIPT
)
  if [[ "$TAB" =~ ^[0-9]+$ ]]; then
    echo "[$(date)] cwd-match -> tab $TAB" >> "$LOG"
  else
    TAB=""
    if [ -n "$TTY" ] && [ -w "$TTY" ]; then
      MARKER="ZZTAB_${$}_${RANDOM}_$(date +%s)_ZZ"
      for try in 1 2 3 4 5 6 7 8; do
        printf '\033]2;%s\a' "$MARKER" > "$TTY" 2>/dev/null
        sleep 0.05
        TAB=$(osascript 2>>"$LOG" <<APPLESCRIPT
on run
  set marker to "$MARKER"
  tell application "Ghostty"
    repeat with w in windows
      repeat with t in tabs of w
        repeat with s in terminals of t
          if name of s contains marker then
            return (index of t) as text
          end if
        end repeat
      end repeat
    end repeat
  end tell
  return ""
end run
APPLESCRIPT
)
        if [[ "$TAB" =~ ^[0-9]+$ ]]; then
          echo "[$(date)] title-marker (try $try) -> tab $TAB" >> "$LOG"
          break
        fi
        TAB=""
      done
      printf '\033]2;\a' > "$TTY" 2>/dev/null
    fi
  fi
fi
[[ "$TAB" =~ ^[0-9]+$ ]] || TAB=""
echo "[$(date)] final tab=[$TAB]" >> "$LOG"

# ---- extract last assistant message SYNC (needs stdin still around) ----
LAST_MSG=""
USER_MSG=""
if [ "$MODE" = "summary" ] && [ -n "$STDIN_JSON" ] && command -v jq >/dev/null; then
  case "$INVOKER" in
    claude-stop|claude-notification)
      TRANSCRIPT=$(printf '%s' "$STDIN_JSON" | jq -r '.transcript_path // empty' 2>/dev/null)
      if [ -n "$TRANSCRIPT" ] && [ -r "$TRANSCRIPT" ]; then
        LAST_MSG=$(jq -sr '
          map(select(.type=="assistant" and (.message.content | type == "array")))
          | last
          | (.message.content // [])
          | map(select(.type=="text") | .text)
          | join(" ")
        ' "$TRANSCRIPT" 2>/dev/null)
        USER_MSG=$(jq -sr '
          map(select(.type=="user" and (.message.content | type == "array" or type == "string")))
          | last
          | if (.message.content | type) == "string"
            then .message.content
            else (.message.content | map(select(.type=="text") | .text) | join(" "))
            end
        ' "$TRANSCRIPT" 2>/dev/null)
      fi
      ;;
    codex|codex-permission)
      LAST_MSG=$(printf '%s' "$STDIN_JSON" | jq -r '.last_assistant_message // empty' 2>/dev/null)
      ;;
  esac
  # Trim to 2500 chars to keep summary call cheap & fast
  LAST_MSG=$(printf '%s' "$LAST_MSG" | head -c 2500)
  USER_MSG=$(printf '%s' "$USER_MSG" | head -c 500)
fi
echo "[$(date)] msg_len=${#LAST_MSG} user_msg_len=${#USER_MSG}" >> "$LOG"

# ---- async: summary + TTS + playback ----
(
  PHRASE=""

  # Try to generate a contextual summary.
  # Endpoint defaults to OpenAI but can be repointed to any OpenAI-compatible API
  # (Ollama, vLLM, llama.cpp, DeepSeek, Together, Groq, etc.) via TAB_TTS_SUMMARY_BASE_URL.
  SUMMARY_BASE_URL="${TAB_TTS_SUMMARY_BASE_URL:-https://api.openai.com/v1}"
  # Auth required only when not pointing at localhost
  SUMMARY_KEY="${TAB_TTS_SUMMARY_KEY:-${OPENAI_TTS_KEY:-}}"
  case "$SUMMARY_BASE_URL" in
    *localhost*|*127.0.0.1*) NEEDS_AUTH=0 ;;
    *) NEEDS_AUTH=1 ;;
  esac

  if [ "$MODE" = "summary" ] && [ -n "$LAST_MSG" ] && command -v jq >/dev/null && { [ "$NEEDS_AUTH" = "0" ] || [ -n "$SUMMARY_KEY" ]; }; then
    SYS_PROMPT='You are an AI coding assistant who just finished a turn helping a developer. The user gives you (1) the developers question and (2) your own response. Generate ONE short conversational sentence (8-14 words) that YOU will say out loud via TTS to hand the result back to the developer. First person ("I pulled...", "I fixed...", "I traced...", "Stuck on..."). Mention concretely what you delivered or found — based on the actual response content. No filler ("Sure!", "Here you go", "I have completed"), no restating the question. If your response is a question back to the user, phrase the handover as a question. Examples: "Pulled the nutrition data on those three pizzas." "Refactored the auth middleware, all tests pass." "Traced the bug to a race condition in queue.ts." "Need to know which environment you are targeting first."'

    USER_BLOB=$(printf 'DEVELOPER QUESTION:\n%s\n\nMY RESPONSE:\n%s' "${USER_MSG:-(unknown)}" "$LAST_MSG")

    SUMMARY_BODY=$(jq -nc \
      --arg model "${TAB_TTS_SUMMARY_MODEL:-gpt-4.1-nano}" \
      --arg system "$SYS_PROMPT" \
      --arg user "$USER_BLOB" \
      '{model:$model,messages:[{role:"system",content:$system},{role:"user",content:$user}],max_completion_tokens:120,temperature:0.4}')

    AUTH_ARGS=()
    [ "$NEEDS_AUTH" = "1" ] && AUTH_ARGS=(-H "Authorization: Bearer ${SUMMARY_KEY}")

    RESP=$(curl -sS --max-time 15 \
      -X POST "${SUMMARY_BASE_URL%/}/chat/completions" \
      "${AUTH_ARGS[@]}" \
      -H "Content-Type: application/json" \
      --data "$SUMMARY_BODY" 2>>"$LOG")
    SUMMARY=$(printf '%s' "$RESP" | jq -r '.choices[0].message.content // empty' 2>/dev/null | tr '\n' ' ' | sed 's/^ *//;s/ *$//')
    echo "[$(date)] summary_base=$SUMMARY_BASE_URL summary=\"$SUMMARY\"" >> "$LOG"

    if [ -n "$SUMMARY" ]; then
      if [ -n "$TAB" ]; then
        PHRASE="Tab ${TAB}: ${SUMMARY}"
      else
        PHRASE="$SUMMARY"
      fi
    fi
  fi

  # Fallbacks if summary unavailable
  if [ -z "$PHRASE" ]; then
    if [ -n "$TAB" ]; then
      PHRASE="${TAB}"
    else
      PHRASE="done"
    fi
  fi
  echo "[$(date)] phrase=\"$PHRASE\"" >> "$LOG"

  # TTS + playback
  if [ -n "${OPENAI_TTS_KEY:-}" ] && command -v jq >/dev/null && command -v curl >/dev/null; then
    VOICE="${TAB_TTS_VOICE:-nova}"
    TTS_MODEL="${TAB_TTS_MODEL:-gpt-4o-mini-tts}"
    INSTRUCTIONS="${TAB_TTS_INSTRUCTIONS:-Speak in a warm, soft, slightly playful and intimate tone. Relaxed and unhurried, like a close friend leaning in.}"
    AUDIO="/tmp/tab-tts-$$-${RANDOM}.mp3"
    BODY=$(jq -nc \
      --arg model "$TTS_MODEL" \
      --arg voice "$VOICE" \
      --arg input "$PHRASE" \
      --arg instructions "$INSTRUCTIONS" \
      '{model:$model,voice:$voice,input:$input,instructions:$instructions}')
    HTTP=$(curl -sS -o "$AUDIO" -w '%{http_code}' \
      -X POST https://api.openai.com/v1/audio/speech \
      -H "Authorization: Bearer ${OPENAI_TTS_KEY}" \
      -H "Content-Type: application/json" \
      --data "$BODY" 2>>"$LOG")
    if [ "$HTTP" = "200" ] && [ -s "$AUDIO" ]; then
      afplay "$AUDIO" >>"$LOG" 2>&1
      rm -f "$AUDIO"
    else
      echo "[$(date)] OpenAI TTS failed (http=$HTTP), using say" >>"$LOG"
      rm -f "$AUDIO" 2>/dev/null
      say "$PHRASE" >>"$LOG" 2>&1
    fi
  else
    say "$PHRASE" >>"$LOG" 2>&1
  fi
) </dev/null >/dev/null 2>&1 &

exit 0
