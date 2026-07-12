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
#   TAB_TTS_PROVIDER        "auto" (default), "qwen", "elevenlabs", "openai", or "say"
#   TAB_TTS_FALLBACK_PROVIDER  Provider to try after the primary fails (default: auto)
#   TAB_TTS_QWEN_PYTHON     Python with qwen_tts installed (default: ~/dev/voicepack/.venv-qwen/bin/python)
#   TAB_TTS_QWEN_RUNNER     Qwen prompt runner (default: ~/dev/voicepack/runners/qwen/speak.py)
#   TAB_TTS_QWEN_VOICE      Voice ID folder (default: ~/dev/voicepack/library/cortana)
#   TAB_TTS_QWEN_AUTO_SERVER Start and use the warm local Qwen server automatically (default: 1)
#   TAB_TTS_QWEN_SERVER_URL Warm Qwen server URL (default: http://127.0.0.1:8765 when auto server is enabled)
#   OPENAI_TTS_KEY          Real api.openai.com key. Falls back to ElevenLabs/`say` if unset.
#   ELEVENLABS_API_KEY      ElevenLabs API key for TAB_TTS_PROVIDER=elevenlabs.
#   TAB_TTS_MODE            "summary" (default) or "number"
#   TAB_TTS_VOICE           OpenAI TTS voice (default: nova)
#   TAB_TTS_MODEL           OpenAI TTS model (default: gpt-4o-mini-tts)
#   ELEVENLABS_VOICE_ID     ElevenLabs voice id (default: JBFqnCBsd6RMkjVDRZzb)
#   ELEVENLABS_MODEL_ID     ElevenLabs model id (default: eleven_flash_v2_5)
#   ELEVENLABS_MIN_REMAINING_CREDITS  Reserve credits before fallback (default: 200)
#   TAB_TTS_INSTRUCTIONS    Voice styling for gpt-4o-mini-tts
#   TAB_TTS_SUMMARY_MODEL   Chat model for summary (default: gpt-4o-mini)
#   TAB_TTS_SUMMARY_BUDGET  "auto" (default), "paid", "local", or "tab"
#   TAB_TTS_DEBUG           Log "[model] } tab } source } spoken text }" when set to 1/on/true
#   TAB_TTS_DEBUG_SPEAK     Also speak the debug prefix when set to 1/on/true
#   TAB_TTS_TIMING          Write machine-readable timing records when not 0/off/false (default: 1)
#   TAB_TTS_TIMING_LOG      JSONL timing log path (default: /tmp/tab-tts-timings.jsonl)
#   TAB_TTS_DEBOUNCE_SEC    Cross-event debounce window (default: 2)
#
# Log: /tmp/tab-tts.log

INVOKER="${1:-claude-stop}"
LOG=/tmp/tab-tts.log
ENV_FILE="$HOME/.config/tab-tts/env"
[ -r "$ENV_FILE" ] && set -a && . "$ENV_FILE" && set +a

MODE="${TAB_TTS_MODE:-summary}"

tab_tts_falsey() {
  case "${1:-}" in
    0|false|FALSE|no|NO|off|OFF) return 0 ;;
    *) return 1 ;;
  esac
}

now_ms() {
  perl -MTime::HiRes=time -e 'printf "%.0f\n", time() * 1000' 2>/dev/null \
    || python3 -c 'import time; print(time.time_ns() // 1000000)' 2>/dev/null \
    || echo "$(($(date +%s) * 1000))"
}

HOOK_START_MS=$(now_ms)
RUN_ID="${INVOKER}-$(date +%s)-$$-${RANDOM}"
TIMING_LOG="${TAB_TTS_TIMING_LOG:-/tmp/tab-tts-timings.jsonl}"

# ---- debounce ----
DEBOUNCE_SEC="${TAB_TTS_DEBOUNCE_SEC:-2}"
LOCK="/tmp/tab-tts-lastfire"
NOW=$(date +%s)
LAST=0
[ -f "$LOCK" ] && LAST=$(cat "$LOCK" 2>/dev/null) && [ -z "$LAST" ] && LAST=0
if [ "$((NOW - LAST))" -lt "$DEBOUNCE_SEC" ]; then
  echo "[$(date)] debounced (gap=$((NOW - LAST))s, invoker=$INVOKER)" >> "$LOG"
  if ! tab_tts_falsey "${TAB_TTS_TIMING:-1}" && command -v jq >/dev/null; then
    jq -nc \
      --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg run_id "$RUN_ID" \
      --arg invoker "$INVOKER" \
      --arg status "debounced" \
      --argjson hook_start_ms "$HOOK_START_MS" \
      --argjson debounce_gap_sec "$((NOW - LAST))" \
      '{ts:$ts,run_id:$run_id,invoker:$invoker,status:$status,hook_start_ms:$hook_start_ms,debounce_gap_sec:$debounce_gap_sec}' >> "$TIMING_LOG" 2>/dev/null
  fi
  exit 0
fi
echo "$NOW" > "$LOCK"

# ---- capture stdin payload synchronously (closes when parent exits) ----
STDIN_JSON=""
if [ ! -t 0 ]; then
  STDIN_JSON=$(cat)
fi
STDIN_DONE_MS=$(now_ms)

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

# ---- detect tab SYNC ----
# OFF by default (TAB_TTS_TAB_DETECT=1 to re-enable): the osascript Ghostty lookup
# was costing ~1.5s on EVERY announcement — 62% of time-to-first-word — while
# returning empty. With it off, first word lands ~1s after the agent finishes.
TAB=""
if ! tab_tts_falsey "${TAB_TTS_TAB_DETECT:-0}" && [ "${TERM_PROGRAM:-}" = "ghostty" ]; then
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
TAB_DONE_MS=$(now_ms)
echo "[$(date)] final tab=[$TAB]" >> "$LOG"

codex_user_msg_from_payload() {
  printf '%s' "$STDIN_JSON" | jq -r '
    .last_user_message // .user_message // .prompt // .input // empty
    | if type == "string" then .
      elif type == "array" then
        map(
          if type == "string" then .
          elif type == "object" then (.text // .content // empty)
          else empty
          end
        ) | join(" ")
      elif type == "object" then (.text // .content // .message // empty)
      else empty
      end
  ' 2>/dev/null
}

codex_session_candidates() {
  SESSION_HINT=$(printf '%s' "$STDIN_JSON" | jq -r '.transcript_path // .session_path // .conversation_path // empty' 2>/dev/null)
  if [ -n "$SESSION_HINT" ] && [ -r "$SESSION_HINT" ]; then
    printf '%s\n' "$SESSION_HINT"
  fi
  find "$HOME/.codex/sessions" -type f -name '*.jsonl' -mtime -2 -exec ls -t {} + 2>/dev/null \
    | head -n 8
}

codex_user_msg_from_session() {
  [ -n "$LAST_MSG" ] || return 0
  codex_session_candidates | while IFS= read -r session_file; do
    [ -r "$session_file" ] || continue
    FOUND=$(
      jq -rs --arg last "$LAST_MSG" '
        def content_text:
          if type == "string" then .
          elif type == "array" then map(content_text) | join("\n")
          elif type == "object" then (.text // .input_text // .output_text // .content // .message // "" | content_text)
          else ""
          end;
        def message_item:
          try (
            select((. | type) == "object")
            | select(.type? == "response_item")
            | select((.payload? | type) == "object")
            | select((.payload? // {} | .type? == "message"))
            | {
                role: (.payload.role // ""),
                text: ((.payload.content // []) | content_text)
              }
            | select(.text != "")
          ) catch empty;
        reduce (.[] | message_item) as $message (
          {last_user: "", found: ""};
          if .found != "" then .
          elif $message.role == "user" then
            .last_user = $message.text
          elif $message.role == "assistant"
            and (
              $message.text == $last
              or ($message.text | contains($last))
              or ($last | contains($message.text))
            )
          then
            .found = .last_user
          else .
          end
        ) | .found
      ' "$session_file" 2>/dev/null
    )
    if [ -n "$FOUND" ]; then
      printf '%s' "$FOUND"
      break
    fi
  done
}

# ---- extract the WHOLE TURN SYNC (needs stdin still around) ----
# Everything the assistant said since the user's last real message, plus a digest of
# tool activity — so the writer summarizes what the turn ACCOMPLISHED, not just the
# sign-off paragraph. Falls back to the last assistant text if the slice is empty.
LAST_MSG=""
USER_MSG=""
TOOLS=""
if [ "$MODE" = "summary" ] && [ -n "$STDIN_JSON" ] && command -v jq >/dev/null; then
  case "$INVOKER" in
    claude-stop|claude-notification)
      TRANSCRIPT=$(printf '%s' "$STDIN_JSON" | jq -r '.transcript_path // empty' 2>/dev/null)
      if [ -n "$TRANSCRIPT" ] && [ -r "$TRANSCRIPT" ]; then
        TURN_JSON=$(jq -sc '
          def entrytext:
            (.message.content // [])
            | (if type == "string" then [{type:"text", text:.}] else . end)
            | map(select(.type=="text") | .text // "")
            | join(" ");
          def is_real_user:
            .type == "user" and
            ((.message.content // [])
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
             | map(.text) | join(" ") | . != "");
          . as $all
          | ([range(0; length) as $i | select($all[$i] | is_real_user) | $i] | last // -1) as $u
          | $all[($u + 1):] as $turn
          | ($turn | map(select(.type=="assistant" and (.message.content | type == "array"))
                     | .message.content[] | select(.type=="tool_use"))) as $uses
          | ($turn
             | map(select(.type=="user")
                   | (.message.content // [])
                   | (if type == "string" then [] else . end)
                   | .[] | select(.type=="tool_result")
                   | (.content // "")
                   | (if type=="string" then .
                      elif type=="array" then (map(select(.type=="text") | .text // "") | join("\n"))
                      else "" end))
             | join("\n") | split("\n") | map(select(length > 0))) as $lines
          | ($lines | map(select(test("(?i)error|fail(ed|ure)?|exception|traceback|denied|warning|passed|refused"))) | .[0:6] | map(.[0:120])) as $hits
          | {
              evidence: ((if ($hits | length) > 0 then $hits else ($lines | .[-2:] | map(.[0:120])) end) | join(" ; ")),
              text: ($turn
                | map(select(.type=="assistant" and (.message.content | type == "array")) | entrytext)
                | map(select(. != "")) | join(" ... ")),
              fallback_text: ($all
                | map(select(.type=="assistant" and (.message.content | type == "array")) | entrytext)
                | map(select(. != "")) | last // ""),
              user: (if $u >= 0 then ($all[$u] | entrytext) else "" end),
              tools: ((($uses | group_by(.name) | map("\(.[0].name) x\(length)") | join(", ")) +
                       (($uses | map(.input.file_path? // empty | split("/") | last) | unique | .[0:5]) as $f
                        | if ($f | length) > 0 then " | files: " + ($f | join(", ")) else "" end)))
            }' "$TRANSCRIPT" 2>/dev/null)
        LAST_MSG=$(printf '%s' "$TURN_JSON" | jq -r '.text // ""' 2>/dev/null)
        [ -n "$LAST_MSG" ] || LAST_MSG=$(printf '%s' "$TURN_JSON" | jq -r '.fallback_text // ""' 2>/dev/null)
        USER_MSG=$(printf '%s' "$TURN_JSON" | jq -r '.user // ""' 2>/dev/null)
        TOOLS=$(printf '%s' "$TURN_JSON" | jq -r '.tools // ""' 2>/dev/null)
        EVIDENCE=$(printf '%s' "$TURN_JSON" | jq -r '.evidence // ""' 2>/dev/null)
      fi
      ;;
    codex|codex-permission)
      LAST_MSG=$(printf '%s' "$STDIN_JSON" | jq -r '.last_assistant_message // empty' 2>/dev/null)
      USER_MSG=$(codex_user_msg_from_payload)
      [ -n "$USER_MSG" ] || USER_MSG=$(codex_user_msg_from_session)
      ;;
  esac
  # Input size is latency-free (parallel prefill) BUT more text degrades the small
  # writer - it stops summarizing and starts continuing the document (echoing prompt
  # labels). So cap TIGHT for focus, tail-biased (the end of a turn is its outcome).
  if [ "${#LAST_MSG}" -gt 3000 ]; then
    LAST_MSG="$(printf '%s' "$LAST_MSG" | head -c 900) ... $(printf '%s' "$LAST_MSG" | tail -c 2100)"
  fi
  USER_MSG=$(printf '%s' "$USER_MSG" | head -c 500)
  TOOLS=$(printf '%s' "$TOOLS" | head -c 200)
  EVIDENCE=$(printf '%s' "${EVIDENCE:-}" | head -c 1200)
fi
MSG_DONE_MS=$(now_ms)
echo "[$(date)] turn_len=${#LAST_MSG} user_msg_len=${#USER_MSG} tools=[$TOOLS]" >> "$LOG"

# ---- async: hand the raw context to the dispatcher on magi, play what comes back ----
# The dispatcher (dashboard.py :8080 /announce) now owns the writer (summary LLM) and the
# mouth (TTS), plus the queue: admission control + per-session coalescing + staleness. This
# hook is deliberately thin — it extracts context (above, sync) and plays audio (below).
(
  ASYNC_START_MS=$(now_ms)
  DISPATCHER="${TAB_TTS_DISPATCHER_URL:-${TAB_TTS_QWEN_SERVER_URL:-}}"
  CLIENT_TTL="${TAB_TTS_DISPATCHER_TIMEOUT_SEC:-45}"

  # Coalescing key = the agent's session/transcript path (stable across a session's turns),
  # so the dispatcher collapses a burst from ONE agent to its latest line while still serving
  # other agents. Falls back to tty/cwd when no transcript path is present.
  SESSION_KEY=$(printf '%s' "$STDIN_JSON" | jq -r '.transcript_path // .session_path // .conversation_path // empty' 2>/dev/null)
  [ -n "$SESSION_KEY" ] || SESSION_KEY="${TTY:-$PWD}"

  HTTP=""; STATUS="failed"; LINE=""; SUMMARY_MS=0; RENDER_MS=0
  TTS_START_MS=$(now_ms); AUDIO_READY_MS="$TTS_START_MS"; PLAY_DONE_MS="$TTS_START_MS"

  if [ -n "$DISPATCHER" ] && command -v jq >/dev/null && command -v curl >/dev/null; then
    BODY=$(jq -nc \
      --arg last "$LAST_MSG" --arg user "$USER_MSG" --arg proj "${PWD##*/}" \
      --arg tools "${TOOLS:-}" --arg evidence "${EVIDENCE:-}" \
      --arg tab "${TAB:-}" --arg cwd "$PWD" --arg session "$SESSION_KEY" --arg mode "$MODE" \
      '{last_msg:$last,user_msg:$user,project:$proj,tools:$tools,evidence:$evidence,tab:$tab,cwd:$cwd,session:$session,mode:$mode}')

    HDRS="/tmp/tab-tts-$$-${RANDOM}.hdr"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    TTS_START_MS=$(now_ms)
    # STREAMING: the dispatcher relays PCM chunks while the voice is still being
    # generated; stream-play.py starts playback on the first chunk. It also handles
    # whole-WAV fallback bodies (RIFF sniff) and empty 204/503 bodies -> silence.
    # HTTP code is read from the saved headers afterward.
    curl -sN --max-time "$CLIENT_TTL" \
      -X POST "${DISPATCHER%/}/announce" \
      -H 'Content-Type: application/json' -H 'Accept: audio/*' \
      -D "$HDRS" --data "$BODY" -o - 2>>"$LOG" \
      | python3 "$SCRIPT_DIR/stream-play.py" >>"$LOG" 2>&1
    PLAY_DONE_MS=$(now_ms)
    AUDIO_READY_MS="$PLAY_DONE_MS"

    HTTP=$(grep -E '^HTTP/' "$HDRS" 2>/dev/null | tail -1 | awk '{print $2}')
    LINE=$(grep -i '^x-line:' "$HDRS" 2>/dev/null | sed 's/^[^:]*: *//;s/\r$//' | head -1)
    SUMMARY_MS=$(grep -i '^x-summary-ms:' "$HDRS" 2>/dev/null | sed 's/^[^:]*: *//;s/\r$//' | head -1)
    RENDER_MS=$(grep -i '^x-render-ms:' "$HDRS" 2>/dev/null | sed 's/^[^:]*: *//;s/\r$//' | head -1)
    case "$SUMMARY_MS" in ""|*[!0-9]*) SUMMARY_MS=0 ;; esac
    case "$RENDER_MS" in ""|*[!0-9]*) RENDER_MS=0 ;; esac

    if [ "$HTTP" = "200" ]; then
      echo "[$(date)] dispatcher streamed: \"$LINE\" (summary_ms=$SUMMARY_MS)" >> "$LOG"
      STATUS="success"
    elif [ "$HTTP" = "204" ] || [ "$HTTP" = "503" ]; then
      # 204 = nothing worth speaking (coalesced/superseded/tab-only); 503 = shed under load.
      # Either way we stay SILENT — no "Done.", no robotic `say`.
      echo "[$(date)] dispatcher: nothing to play (http=$HTTP), staying silent" >> "$LOG"
      PLAY_DONE_MS=$(now_ms); STATUS="silent"
    else
      echo "[$(date)] dispatcher unreachable/failed (http=$HTTP)" >> "$LOG"
      PLAY_DONE_MS=$(now_ms); STATUS="failed"
      # Degraded fallback is OFF by default: when magi is down, silence beats the robot voice.
      # Set TAB_TTS_FALLBACK_ON_FAIL=1 to speak a minimal local `say` on hard failure.
      case "${TAB_TTS_FALLBACK_ON_FAIL:-0}" in
        1|true|TRUE|yes|YES|on|ON)
          if [ -n "${TAB:-}" ]; then say -v "${TAB_TTS_SAY_VOICE:-Samantha}" "Tab ${TAB}." >>"$LOG" 2>&1; fi
          ;;
      esac
    fi
    rm -f "$HDRS" 2>/dev/null
  else
    echo "[$(date)] dispatcher not configured (set TAB_TTS_DISPATCHER_URL or TAB_TTS_QWEN_SERVER_URL)" >> "$LOG"
  fi

  # ---- compact timing record (schema evolved: dispatcher path) ----
  if ! tab_tts_falsey "${TAB_TTS_TIMING:-1}" && command -v jq >/dev/null; then
    TTS_MS=$((AUDIO_READY_MS - TTS_START_MS))
    PLAY_MS=$((PLAY_DONE_MS - AUDIO_READY_MS))
    HOOK_SYNC_MS=$((MSG_DONE_MS - HOOK_START_MS))
    TOTAL_PLAY_MS=$((PLAY_DONE_MS - HOOK_START_MS))
    jq -nc \
      --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg run_id "$RUN_ID" --arg invoker "$INVOKER" \
      --arg status "$STATUS" --arg provider "dispatcher" --arg http "${HTTP:-}" --arg mode "$MODE" \
      --arg tab "${TAB:-}" --arg cwd "$PWD" --arg session "$SESSION_KEY" --arg line "$LINE" \
      --argjson hook_start_ms "$HOOK_START_MS" --argjson hook_sync_ms "$HOOK_SYNC_MS" \
      --argjson summary_ms "$SUMMARY_MS" --argjson tts_ms "$TTS_MS" --argjson play_ms "$PLAY_MS" \
      --argjson render_ms "$RENDER_MS" --argjson total_to_play_done_ms "$TOTAL_PLAY_MS" \
      '{ts:$ts,run_id:$run_id,invoker:$invoker,status:$status,provider:$provider,http_status:$http,mode:$mode,tab:$tab,cwd:$cwd,session:$session,line:$line,hook_start_ms:$hook_start_ms,hook_sync_ms:$hook_sync_ms,summary_ms:$summary_ms,tts_ms:$tts_ms,play_ms:$play_ms,render_ms:$render_ms,total_to_play_done_ms:$total_to_play_done_ms}' >> "$TIMING_LOG" 2>/dev/null
  fi
) </dev/null >/dev/null 2>&1 &

exit 0
