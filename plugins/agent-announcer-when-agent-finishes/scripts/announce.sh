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
        # Find the last user message that contains real human-typed text,
        # skipping tool_result wrappers, system-reminders, and slash-command
        # output blocks (all of which appear as type=user in Claude's transcript).
        USER_MSG=$(jq -sr '
          map(select(.type=="user"))
          | map(
              (.message.content // [])
              | (if type == "string" then [{type:"text", text:.}] else . end)
              | map(select(
                  .type == "text"
                  and ((.text // "") | startswith("<system-reminder>") | not)
                  and ((.text // "") | startswith("<command-") | not)
                  and ((.text // "") | startswith("<local-command-") | not)
                  and ((.text // "") | startswith("<bash-input>") | not)
                  and ((.text // "") | startswith("<bash-stdout>") | not)
                  and ((.text // "") | startswith("<bash-stderr>") | not)
                  and ((.text // "") | startswith("Caveat:") | not)
                ))
              | map(.text)
              | join(" ")
            )
          | map(select(. != "" and . != null))
          | last // ""
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
    SYS_PROMPT='You just finished an assistant turn. You will see what you said. Write ONE short conversational sentence (6-14 words) that you will say out loud to hand back to the developer. First person, casual, like talking to a friend.

Rules:
- Do NOT invent actions. If you only PROPOSED something ("Want me to...", "Should I..."), you have NOT done it — say you are waiting on their go-ahead.
- If you ASKED the developer a question, restate that question briefly as YOUR question to them.
- If your response was just thanks / emoji / agreement, say something brief and warm.
- If you actually did work, mention what specifically, past tense.

Vary your phrasing every turn. Match the tone of your response.

Output ONLY the line — no quotes, no labels, no preamble.'

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

    # Safety guard: a "summary" longer than ~200 chars is almost certainly the
    # model echoing the input or rambling. Reject it and fall back to tab number.
    SUMMARY_MAX="${TAB_TTS_SUMMARY_MAX_CHARS:-220}"
    if [ "${#SUMMARY}" -gt "$SUMMARY_MAX" ]; then
      echo "[$(date)] summary rejected (${#SUMMARY} chars > $SUMMARY_MAX): \"${SUMMARY:0:80}...\"" >> "$LOG"
      SUMMARY=""
    fi

    echo "[$(date)] summary_base=$SUMMARY_BASE_URL model=${TAB_TTS_SUMMARY_MODEL:-gpt-4.1-nano} summary=\"$SUMMARY\"" >> "$LOG"

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
