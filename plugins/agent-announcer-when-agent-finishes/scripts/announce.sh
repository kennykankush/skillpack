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
      USER_MSG=$(codex_user_msg_from_payload)
      [ -n "$USER_MSG" ] || USER_MSG=$(codex_user_msg_from_session)
      ;;
  esac
  # Trim to 2500 chars to keep summary call cheap & fast
  LAST_MSG=$(printf '%s' "$LAST_MSG" | head -c 2500)
  USER_MSG=$(printf '%s' "$USER_MSG" | head -c 500)
fi
MSG_DONE_MS=$(now_ms)
echo "[$(date)] msg_len=${#LAST_MSG} user_msg_len=${#USER_MSG}" >> "$LOG"

# ---- async: summary + TTS + playback ----
(
  ASYNC_START_MS=$(now_ms)
  SUMMARY_ATTEMPTED=0
  SUMMARY_START_MS=0
  SUMMARY_DONE_MS=0
  SUMMARY_MS=0
  SUMMARY_STATUS="skipped"
  SUMMARY_REJECT_REASON=""
  # Per-hook metric only: 1 means this invocation launched the warm server.
  # The real server state is checked via GET /health on the localhost server.
  QWEN_SERVER_STARTED_THIS_RUN=0
  QWEN_SERVER_WAIT_MS=0
  PHRASE_READY_MS=0
  PHRASE=""

  normalize_tts_provider() {
    printf '%s' "${1:-auto}" | tr '[:upper:]' '[:lower:]' | tr '_' '-'
  }

  PRIMARY_PROVIDER=$(normalize_tts_provider "${TAB_TTS_PROVIDER:-${TAB_TTS_VOICE_CHANNEL:-${VOICE_CHANNEL:-auto}}}")
  FALLBACK_PROVIDER=$(normalize_tts_provider "${TAB_TTS_FALLBACK_PROVIDER:-auto}")

  summary_budget_for_provider() {
    case "$(normalize_tts_provider "$1")" in
      qwen|qwen3|local-qwen)
        printf 'local'
        ;;
      elevenlabs|eleven-labs|openai)
        printf 'paid'
        ;;
      auto)
        if [ -n "${ELEVENLABS_API_KEY:-}" ] || [ -n "${OPENAI_TTS_KEY:-}" ]; then
          printf 'paid'
        else
          printf 'tab'
        fi
        ;;
      *)
        printf 'tab'
        ;;
    esac
  }

  SUMMARY_BUDGET=$(normalize_tts_provider "${TAB_TTS_SUMMARY_BUDGET:-auto}")
  [ "$SUMMARY_BUDGET" = "auto" ] && SUMMARY_BUDGET=$(summary_budget_for_provider "$PRIMARY_PROVIDER")
  case "$SUMMARY_BUDGET" in
    local|rich)
      SUMMARY_BUDGET="local"
      SUMMARY_WORD_RANGE="${TAB_TTS_LOCAL_SUMMARY_WORDS:-12-24 words}"
      SUMMARY_MAX_CHARS="${TAB_TTS_SUMMARY_MAX_CHARS:-${TAB_TTS_LOCAL_SUMMARY_MAX_CHARS:-220}}"
      SUMMARY_MAX_TOKENS="${TAB_TTS_SUMMARY_MAX_TOKENS:-${TAB_TTS_LOCAL_SUMMARY_MAX_TOKENS:-140}}"
      SUMMARY_BUDGET_NOTE="Budget profile: local TTS. You may use a slightly richer handover because speech is generated locally. Keep it one sentence and useful, not verbose."
      ;;
    paid|cloud|short)
      SUMMARY_BUDGET="paid"
      SUMMARY_WORD_RANGE="${TAB_TTS_PAID_SUMMARY_WORDS:-6-10 words}"
      SUMMARY_MAX_CHARS="${TAB_TTS_SUMMARY_MAX_CHARS:-${TAB_TTS_PAID_SUMMARY_MAX_CHARS:-90}}"
      SUMMARY_MAX_TOKENS="${TAB_TTS_SUMMARY_MAX_TOKENS:-${TAB_TTS_PAID_SUMMARY_MAX_TOKENS:-60}}"
      SUMMARY_BUDGET_NOTE="Budget profile: paid TTS. Keep it extremely compact because every character can cost money. If the useful summary would become vague or awkward, output exactly __TAB_ONLY__."
      ;;
    tab|number|none)
      SUMMARY_BUDGET="tab"
      SUMMARY_WORD_RANGE="0 words"
      SUMMARY_MAX_CHARS=0
      SUMMARY_MAX_TOKENS=1
      SUMMARY_BUDGET_NOTE="Budget profile: tab only."
      SUMMARY_STATUS="skipped_budget"
      ;;
    *)
      SUMMARY_BUDGET="paid"
      SUMMARY_WORD_RANGE="${TAB_TTS_PAID_SUMMARY_WORDS:-6-10 words}"
      SUMMARY_MAX_CHARS="${TAB_TTS_SUMMARY_MAX_CHARS:-${TAB_TTS_PAID_SUMMARY_MAX_CHARS:-90}}"
      SUMMARY_MAX_TOKENS="${TAB_TTS_SUMMARY_MAX_TOKENS:-${TAB_TTS_PAID_SUMMARY_MAX_TOKENS:-60}}"
      SUMMARY_BUDGET_NOTE="Budget profile: paid TTS. Keep it extremely compact because every character can cost money. If the useful summary would become vague or awkward, output exactly __TAB_ONLY__."
      ;;
  esac
  case "$SUMMARY_MAX_CHARS" in ""|*[!0-9]*) SUMMARY_MAX_CHARS=120 ;; esac
  case "$SUMMARY_MAX_TOKENS" in ""|*[!0-9]*) SUMMARY_MAX_TOKENS=80 ;; esac
  echo "[$(date)] summary_budget=$SUMMARY_BUDGET words=\"$SUMMARY_WORD_RANGE\" max_chars=$SUMMARY_MAX_CHARS max_tokens=$SUMMARY_MAX_TOKENS provider=$PRIMARY_PROVIDER" >> "$LOG"

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

  static_summary_from_response() {
    printf '%s' "$LAST_MSG" | perl -0ne '
      if (/Pushed to\s+`?([^`\n.]+?)`?\s+main\.\s+Commit:\s+`?([0-9a-f]{7,40})(?:\s+([^`\n]+))?`?/is) {
        my $repo = $1;
        my $hash = substr($2, 0, 7);
        my $subject = $3 // "";
        $repo =~ s/^\s+|\s+$//g;
        $subject =~ s/^\s+|\s+$//g;
        if ($subject ne "") {
          print "Pushed " . $subject . " to " . $repo . " main.";
        } else {
          print "Pushed " . $repo . " main with commit " . $hash . ".";
        }
        exit;
      }
      if (/Verified\s+`?origin\/main`?\s+matches\s+local\s+`?HEAD`?/is) {
        print "Verified origin main matches local HEAD.";
        exit;
      }
    '
  }

  if [ "$MODE" = "summary" ] && [ "$SUMMARY_BUDGET" != "tab" ] && [ -n "$LAST_MSG" ]; then
    STATIC_SUMMARY=$(static_summary_from_response)
    if [ -n "$STATIC_SUMMARY" ]; then
      SUMMARY="$STATIC_SUMMARY"
      SUMMARY_STATUS="static"
      echo "[$(date)] summary_static=\"$SUMMARY\"" >> "$LOG"
      if [ -n "$TAB" ]; then
        PHRASE="Tab ${TAB}: ${SUMMARY}"
      else
        PHRASE="$SUMMARY"
      fi
    fi
  fi

  if [ -z "$PHRASE" ] && [ "$MODE" = "summary" ] && [ "$SUMMARY_BUDGET" != "tab" ] && [ -n "$LAST_MSG" ] && command -v jq >/dev/null && { [ "$NEEDS_AUTH" = "0" ] || [ -n "$SUMMARY_KEY" ]; }; then
    SUMMARY_ATTEMPTED=1
    SUMMARY_STATUS="requested"
    LAST_MSG_HAS_QUESTION=0
    case "$LAST_MSG" in
      *\?*) LAST_MSG_HAS_QUESTION=1 ;;
    esac

    SYS_PROMPT=$(cat <<PROMPT
You are the assistant who just finished a turn. Write ONE conversational sentence (${SUMMARY_WORD_RANGE}) that you will say out loud to hand back to the developer.

${SUMMARY_BUDGET_NOTE}

Your only source of truth is ASSISTANT_RESPONSE_TO_SUMMARIZE.
Speak as the assistant handing control back to the developer.
Use "I" only for actions ASSISTANT_RESPONSE_TO_SUMMARIZE explicitly says the assistant did.
Do not speak as the developer. Do not summarize or repeat USER_MESSAGE_CONTEXT unless the assistant explicitly asked a follow-up.

Rules:
- Summarize ASSISTANT_RESPONSE_TO_SUMMARIZE, not USER_MESSAGE_CONTEXT.
- If the assistant answered a user question, state the answer briefly.
- If the assistant gave facts or steps, report those facts or steps as available, not as completed work.
- Do NOT claim you checked, found, fixed, tested, changed, filed, pushed, or ran anything unless ASSISTANT_RESPONSE_TO_SUMMARIZE says that happened.
- Output a question only if ASSISTANT_RESPONSE_TO_SUMMARIZE itself asks the developer a direct question.
- Do NOT invent actions. If you only PROPOSED something ("Want me to...", "Should I..."), you have NOT done it - say you are waiting on their go-ahead.
- If your response was just thanks / emoji / agreement, say something brief and warm.
- If you actually did work, mention what specifically, past tense.
- If you cannot say something concrete inside the budget, output exactly __TAB_ONLY__.
- Do NOT praise the work. Avoid phrases like "great fix", "nice work", or "looks good" unless they are quoting the assistant response.
- Do NOT add generic follow-up questions like "anything else?", "next steps?", or "do you want me to...".

Vary your phrasing every turn. Match the tone of your response.

Output ONLY the line - no quotes, no labels, no preamble.
PROMPT
)

    USER_BLOB=$(printf 'USER_MESSAGE_CONTEXT:\n%s\n\nASSISTANT_RESPONSE_TO_SUMMARIZE:\n%s\n\nASSISTANT_RESPONSE_HAS_QUESTION_MARK: %s' "${USER_MSG:-(unknown)}" "$LAST_MSG" "$LAST_MSG_HAS_QUESTION")

    SUMMARY_BODY=$(jq -nc \
      --arg model "${TAB_TTS_SUMMARY_MODEL:-gpt-4.1-nano}" \
      --arg system "$SYS_PROMPT" \
      --arg user "$USER_BLOB" \
      --argjson max_tokens "$SUMMARY_MAX_TOKENS" \
      '{model:$model,messages:[{role:"system",content:$system},{role:"user",content:$user}],max_completion_tokens:$max_tokens,temperature:0.4}')

    AUTH_ARGS=()
    [ "$NEEDS_AUTH" = "1" ] && AUTH_ARGS=(-H "Authorization: Bearer ${SUMMARY_KEY}")

    SUMMARY_START_MS=$(now_ms)
    RESP=$(curl -sS --max-time 15 \
      -X POST "${SUMMARY_BASE_URL%/}/chat/completions" \
      "${AUTH_ARGS[@]}" \
      -H "Content-Type: application/json" \
      --data "$SUMMARY_BODY" 2>>"$LOG")
    SUMMARY_DONE_MS=$(now_ms)
    SUMMARY_MS=$((SUMMARY_DONE_MS - SUMMARY_START_MS))
    SUMMARY=$(printf '%s' "$RESP" | jq -r '.choices[0].message.content // empty' 2>/dev/null | tr '\n' ' ' | sed 's/^ *//;s/ *$//')

    case "$SUMMARY" in
      "__TAB_ONLY__"|TAB_ONLY|tab|Tab)
        echo "[$(date)] summary budget chose tab-only" >> "$LOG"
        SUMMARY_STATUS="budget_tab"
        SUMMARY=""
        ;;
    esac

    # Safety guard: a "summary" longer than ~200 chars is almost certainly the
    # model echoing the input or rambling. Reject it and fall back to tab number.
    if [ "${#SUMMARY}" -gt "$SUMMARY_MAX_CHARS" ]; then
      echo "[$(date)] summary rejected (${#SUMMARY} chars > $SUMMARY_MAX_CHARS, budget=$SUMMARY_BUDGET): \"${SUMMARY:0:80}...\"" >> "$LOG"
      SUMMARY_STATUS="rejected"
      SUMMARY_REJECT_REASON="too_long"
      SUMMARY=""
    fi

	    if [ -n "$SUMMARY" ] && [ "$LAST_MSG_HAS_QUESTION" = "0" ]; then
	      CLEAN_SUMMARY=$(printf '%s' "$SUMMARY" | perl -CS -pe 's/\s+(Is there anything else[^?]*\?|Anything else[^?]*\?|Do you want me[^?]*\?|Should I[^?]*\?|Ready to[^?]*\?|Next steps\?)$//i; s/^(Great fix!|Nice work!|Looks good[.!]?)\s*//i; s/\s+$//')
	      if [ -n "$CLEAN_SUMMARY" ] && [ "$CLEAN_SUMMARY" != "$SUMMARY" ]; then
	        echo "[$(date)] summary stripped generic follow-up: \"$SUMMARY\" -> \"$CLEAN_SUMMARY\"" >> "$LOG"
	        SUMMARY="$CLEAN_SUMMARY"
	      fi
	      case "$SUMMARY" in
	        *\?)
	          echo "[$(date)] summary rejected (question without assistant question): \"$SUMMARY\"" >> "$LOG"
          SUMMARY_STATUS="rejected"
          SUMMARY_REJECT_REASON="question_without_assistant_question"
          SUMMARY=""
          ;;
      esac
    fi

    if [ -n "$SUMMARY" ]; then
      SUMMARY_STATUS="accepted"
    elif [ "$SUMMARY_STATUS" = "requested" ]; then
      SUMMARY_STATUS="empty"
    fi

    echo "[$(date)] summary_base=$SUMMARY_BASE_URL model=${TAB_TTS_SUMMARY_MODEL:-gpt-4.1-nano} budget=$SUMMARY_BUDGET summary=\"$SUMMARY\"" >> "$LOG"

    if [ -n "$SUMMARY" ]; then
      if [ -n "$TAB" ]; then
        PHRASE="Tab ${TAB}: ${SUMMARY}"
      else
        PHRASE="$SUMMARY"
      fi
    fi
  fi

  tab_only_phrase() {
    if [ -n "$TAB" ]; then
      printf 'Tab %s.' "$TAB"
    else
      printf 'Done.'
    fi
  }

  # Fallbacks if summary unavailable
  if [ -z "$PHRASE" ]; then
    PHRASE="$(tab_only_phrase)"
  fi
  echo "[$(date)] phrase=\"$PHRASE\"" >> "$LOG"
  PHRASE_READY_MS=$(now_ms)

  # TTS + playback
  is_tts_truthy() {
    case "${1:-0}" in
      1|true|TRUE|yes|YES|on|ON) return 0 ;;
      *) return 1 ;;
    esac
  }

  debug_tts_line() {
    DEBUG_TAB="${TAB:-no-tab}"
    DEBUG_SOURCE="${2:-unknown-source}"
    printf '[%s] } %s } %s } %s }' "$1" "$DEBUG_TAB" "$DEBUG_SOURCE" "$PHRASE"
  }

  log_tts_debug() {
    is_tts_truthy "${TAB_TTS_DEBUG:-0}" && echo "[$(date)] tts_debug=$(debug_tts_line "$1" "$2")" >> "$LOG"
  }

  tts_phrase_for_model() {
    if is_tts_truthy "${TAB_TTS_DEBUG_SPEAK:-0}"; then
      debug_tts_line "$1" "$2"
    else
      printf '%s' "$PHRASE"
    fi
  }

  log_audio_ready() {
    PROVIDER="$1"
    MODEL_NAME="$2"
    SOURCE_NAME="$3"
    TTS_START="$4"
    AUDIO_READY="$5"
    TTS_MS=$((AUDIO_READY - TTS_START))
    TOTAL_MS=$((AUDIO_READY - HOOK_START_MS))
    echo "[$(date)] audio_ready run_id=$RUN_ID provider=$PROVIDER model=$MODEL_NAME source=$SOURCE_NAME tts_ms=${TTS_MS} total_to_audio_ready_ms=${TOTAL_MS}" >> "$LOG"
  }

  emit_timing() {
    STATUS="$1"
    PROVIDER="$2"
    MODEL_NAME="$3"
    SOURCE_NAME="$4"
    AUDIO_PATH="$5"
    HTTP_STATUS="$6"
    TTS_START="$7"
    AUDIO_READY="$8"
    PLAY_DONE="$9"

    if tab_tts_falsey "${TAB_TTS_TIMING:-1}"; then
      return 0
    fi

    TTS_MS=$((AUDIO_READY - TTS_START))
    PLAY_MS=$((PLAY_DONE - AUDIO_READY))
    HOOK_SYNC_MS=$((MSG_DONE_MS - HOOK_START_MS))
    STDIN_MS=$((STDIN_DONE_MS - HOOK_START_MS))
    TAB_MS=$((TAB_DONE_MS - STDIN_DONE_MS))
    MSG_MS=$((MSG_DONE_MS - TAB_DONE_MS))
    ASYNC_DELAY_MS=$((ASYNC_START_MS - MSG_DONE_MS))
    PHRASE_READY_TOTAL_MS=$((PHRASE_READY_MS - HOOK_START_MS))
    TOTAL_AUDIO_MS=$((AUDIO_READY - HOOK_START_MS))
    TOTAL_PLAY_MS=$((PLAY_DONE - HOOK_START_MS))

    echo "[$(date)] timing run_id=$RUN_ID status=$STATUS provider=$PROVIDER hook_sync_ms=$HOOK_SYNC_MS summary_ms=$SUMMARY_MS tts_ms=$TTS_MS play_ms=$PLAY_MS total_to_audio_ready_ms=$TOTAL_AUDIO_MS total_to_play_done_ms=$TOTAL_PLAY_MS" >> "$LOG"

    command -v jq >/dev/null || return 0
    jq -nc \
      --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg run_id "$RUN_ID" \
      --arg invoker "$INVOKER" \
      --arg status "$STATUS" \
      --arg provider "$PROVIDER" \
      --arg model "$MODEL_NAME" \
      --arg source "$SOURCE_NAME" \
      --arg audio "$AUDIO_PATH" \
      --arg http_status "$HTTP_STATUS" \
      --arg mode "$MODE" \
      --arg tab "${TAB:-}" \
      --arg cwd "$PWD" \
      --arg term "${TERM_PROGRAM:-}" \
      --arg summary_base_url "$SUMMARY_BASE_URL" \
      --arg summary_model "${TAB_TTS_SUMMARY_MODEL:-gpt-4.1-nano}" \
      --arg summary_budget "$SUMMARY_BUDGET" \
      --arg summary_word_range "$SUMMARY_WORD_RANGE" \
      --arg summary_status "$SUMMARY_STATUS" \
      --arg summary_reject_reason "$SUMMARY_REJECT_REASON" \
      --arg fallback_provider "$FALLBACK_PROVIDER" \
      --argjson hook_start_ms "$HOOK_START_MS" \
      --argjson stdin_len "${#STDIN_JSON}" \
      --argjson last_msg_len "${#LAST_MSG}" \
      --argjson user_msg_len "${#USER_MSG}" \
      --argjson phrase_chars "${#PHRASE}" \
      --argjson stdin_ms "$STDIN_MS" \
      --argjson tab_detect_ms "$TAB_MS" \
      --argjson message_extract_ms "$MSG_MS" \
      --argjson hook_sync_ms "$HOOK_SYNC_MS" \
      --argjson async_delay_ms "$ASYNC_DELAY_MS" \
      --argjson summary_attempted "$SUMMARY_ATTEMPTED" \
      --argjson summary_ms "$SUMMARY_MS" \
      --argjson qwen_server_started "$QWEN_SERVER_STARTED_THIS_RUN" \
      --argjson qwen_server_wait_ms "$QWEN_SERVER_WAIT_MS" \
      --argjson phrase_ready_ms "$PHRASE_READY_TOTAL_MS" \
      --argjson tts_ms "$TTS_MS" \
      --argjson play_ms "$PLAY_MS" \
      --argjson total_to_audio_ready_ms "$TOTAL_AUDIO_MS" \
      --argjson total_to_play_done_ms "$TOTAL_PLAY_MS" \
      '{ts:$ts,run_id:$run_id,invoker:$invoker,status:$status,provider:$provider,model:$model,source:$source,audio:$audio,http_status:$http_status,mode:$mode,tab:$tab,cwd:$cwd,term:$term,summary_base_url:$summary_base_url,summary_model:$summary_model,summary_budget:$summary_budget,summary_word_range:$summary_word_range,summary_status:$summary_status,summary_reject_reason:$summary_reject_reason,fallback_provider:$fallback_provider,hook_start_ms:$hook_start_ms,stdin_len:$stdin_len,last_msg_len:$last_msg_len,user_msg_len:$user_msg_len,phrase_chars:$phrase_chars,stdin_ms:$stdin_ms,tab_detect_ms:$tab_detect_ms,message_extract_ms:$message_extract_ms,hook_sync_ms:$hook_sync_ms,async_delay_ms:$async_delay_ms,summary_attempted:$summary_attempted,summary_ms:$summary_ms,qwen_server_started:$qwen_server_started,qwen_server_wait_ms:$qwen_server_wait_ms,phrase_ready_ms:$phrase_ready_ms,tts_ms:$tts_ms,play_ms:$play_ms,total_to_audio_ready_ms:$total_to_audio_ready_ms,total_to_play_done_ms:$total_to_play_done_ms}' >> "$TIMING_LOG" 2>/dev/null
  }

  play_openai_tts() {
    [ -n "${OPENAI_TTS_KEY:-}" ] || return 1
    command -v jq >/dev/null || return 1
    command -v curl >/dev/null || return 1
    VOICE="${TAB_TTS_VOICE:-nova}"
    TTS_MODEL="${TAB_TTS_MODEL:-gpt-4o-mini-tts}"
    INSTRUCTIONS="${TAB_TTS_INSTRUCTIONS:-Speak in a warm, soft, slightly playful and intimate tone. Relaxed and unhurried, like a close friend leaning in.}"
    log_tts_debug "$TTS_MODEL" "$VOICE"
    SPOKEN_PHRASE=$(tts_phrase_for_model "$TTS_MODEL" "$VOICE")
    AUDIO="/tmp/tab-tts-$$-${RANDOM}.mp3"
    BODY=$(jq -nc \
      --arg model "$TTS_MODEL" \
      --arg voice "$VOICE" \
      --arg input "$SPOKEN_PHRASE" \
      --arg instructions "$INSTRUCTIONS" \
      '{model:$model,voice:$voice,input:$input,instructions:$instructions}')
    TTS_START_MS=$(now_ms)
    HTTP=$(curl -sS -o "$AUDIO" -w '%{http_code}' \
      -X POST https://api.openai.com/v1/audio/speech \
      -H "Authorization: Bearer ${OPENAI_TTS_KEY}" \
      -H "Content-Type: application/json" \
      --data "$BODY" 2>>"$LOG")
    AUDIO_READY_MS=$(now_ms)
    if [ "$HTTP" = "200" ] && [ -s "$AUDIO" ]; then
      echo "[$(date)] tts_provider=openai model=$TTS_MODEL voice=$VOICE http=$HTTP" >> "$LOG"
      log_audio_ready "openai" "$TTS_MODEL" "$VOICE" "$TTS_START_MS" "$AUDIO_READY_MS"
      afplay "$AUDIO" >>"$LOG" 2>&1
      PLAY_DONE_MS=$(now_ms)
      emit_timing "success" "openai" "$TTS_MODEL" "$VOICE" "$AUDIO" "$HTTP" "$TTS_START_MS" "$AUDIO_READY_MS" "$PLAY_DONE_MS"
      rm -f "$AUDIO"
      return 0
    fi
    echo "[$(date)] OpenAI TTS failed (http=$HTTP)" >>"$LOG"
    emit_timing "failed" "openai" "$TTS_MODEL" "$VOICE" "$AUDIO" "$HTTP" "$TTS_START_MS" "$AUDIO_READY_MS" "$AUDIO_READY_MS"
    rm -f "$AUDIO" 2>/dev/null
    return 1
  }

  elevenlabs_credit_check_ok() {
    [ "${ELEVENLABS_CHECK_CREDITS:-1}" = "1" ] || return 0
    command -v jq >/dev/null || return 0
    command -v curl >/dev/null || return 0
    SUBSCRIPTION=$(curl -sS --max-time 8 \
      -H "xi-api-key: ${ELEVENLABS_API_KEY}" \
      https://api.elevenlabs.io/v1/user/subscription 2>>"$LOG") || return 0
    CHARACTER_COUNT=$(printf '%s' "$SUBSCRIPTION" | jq -r '.character_count // empty' 2>/dev/null)
    CHARACTER_LIMIT=$(printf '%s' "$SUBSCRIPTION" | jq -r '.character_limit // empty' 2>/dev/null)
    case "$CHARACTER_COUNT" in ""|*[!0-9]*) return 0 ;; esac
    case "$CHARACTER_LIMIT" in ""|*[!0-9]*) return 0 ;; esac
    MIN_REMAINING="${ELEVENLABS_MIN_REMAINING_CREDITS:-200}"
    case "$MIN_REMAINING" in ""|*[!0-9]*) MIN_REMAINING=200 ;; esac
    REMAINING=$((CHARACTER_LIMIT - CHARACTER_COUNT))
    NEEDED=$((${#PHRASE} + MIN_REMAINING))
    echo "[$(date)] elevenlabs_credits remaining=$REMAINING phrase_chars=${#PHRASE} reserve=$MIN_REMAINING" >> "$LOG"
    [ "$REMAINING" -ge "$NEEDED" ]
  }

  play_elevenlabs_tts() {
    [ -n "${ELEVENLABS_API_KEY:-}" ] || return 1
    command -v jq >/dev/null || return 1
    command -v curl >/dev/null || return 1
    elevenlabs_credit_check_ok || {
      echo "[$(date)] ElevenLabs TTS skipped: low credits" >> "$LOG"
      return 1
    }
    ELEVEN_VOICE_ID="${ELEVENLABS_VOICE_ID:-JBFqnCBsd6RMkjVDRZzb}"
    ELEVEN_MODEL_ID="${ELEVENLABS_MODEL_ID:-eleven_flash_v2_5}"
    ELEVEN_OUTPUT_FORMAT="${ELEVENLABS_OUTPUT_FORMAT:-mp3_44100_128}"
    log_tts_debug "$ELEVEN_MODEL_ID" "$ELEVEN_VOICE_ID"
    SPOKEN_PHRASE=$(tts_phrase_for_model "$ELEVEN_MODEL_ID" "$ELEVEN_VOICE_ID")
    AUDIO="/tmp/tab-tts-$$-${RANDOM}.mp3"
    BODY=$(jq -nc \
      --arg text "$SPOKEN_PHRASE" \
      --arg model "$ELEVEN_MODEL_ID" \
      '{text:$text,model_id:$model}')
    TTS_START_MS=$(now_ms)
    HTTP=$(curl -sS -o "$AUDIO" -w '%{http_code}' \
      -X POST "https://api.elevenlabs.io/v1/text-to-speech/${ELEVEN_VOICE_ID}?output_format=${ELEVEN_OUTPUT_FORMAT}" \
      -H "xi-api-key: ${ELEVENLABS_API_KEY}" \
      -H "Accept: audio/mpeg" \
      -H "Content-Type: application/json" \
      --data "$BODY" 2>>"$LOG")
    AUDIO_READY_MS=$(now_ms)
    if [ "$HTTP" = "200" ] && [ -s "$AUDIO" ]; then
      echo "[$(date)] tts_provider=elevenlabs model=$ELEVEN_MODEL_ID voice=$ELEVEN_VOICE_ID output=$ELEVEN_OUTPUT_FORMAT http=$HTTP" >> "$LOG"
      log_audio_ready "elevenlabs" "$ELEVEN_MODEL_ID" "$ELEVEN_VOICE_ID" "$TTS_START_MS" "$AUDIO_READY_MS"
      afplay "$AUDIO" >>"$LOG" 2>&1
      PLAY_DONE_MS=$(now_ms)
      emit_timing "success" "elevenlabs" "$ELEVEN_MODEL_ID" "$ELEVEN_VOICE_ID" "$AUDIO" "$HTTP" "$TTS_START_MS" "$AUDIO_READY_MS" "$PLAY_DONE_MS"
      rm -f "$AUDIO"
      return 0
    fi
    echo "[$(date)] ElevenLabs TTS failed (http=$HTTP)" >>"$LOG"
    emit_timing "failed" "elevenlabs" "$ELEVEN_MODEL_ID" "$ELEVEN_VOICE_ID" "$AUDIO" "$HTTP" "$TTS_START_MS" "$AUDIO_READY_MS" "$AUDIO_READY_MS"
    rm -f "$AUDIO" 2>/dev/null
    return 1
  }

  play_qwen_tts() {
    QWEN_PYTHON="${TAB_TTS_QWEN_PYTHON:-$HOME/dev/voicepack/.venv-qwen/bin/python}"
    QWEN_RUNNER="${TAB_TTS_QWEN_RUNNER:-$HOME/dev/voicepack/runners/qwen/speak.py}"
    QWEN_VOICE="${TAB_TTS_QWEN_VOICE:-${TAB_TTS_QWEN_VOICEPACK:-$HOME/dev/voicepack/library/cortana}}"
    QWEN_DEVICE="${TAB_TTS_QWEN_DEVICE:-}"
    QWEN_DTYPE="${TAB_TTS_QWEN_DTYPE:-}"
    QWEN_MODEL="${TAB_TTS_QWEN_MODEL:-}"
    QWEN_SEED="${TAB_TTS_QWEN_SEED:-}"
    QWEN_AUTO_SERVER="${TAB_TTS_QWEN_AUTO_SERVER:-1}"
    QWEN_SERVER_URL="${TAB_TTS_QWEN_SERVER_URL:-}"
    if [ -z "$QWEN_SERVER_URL" ] && ! tab_tts_falsey "$QWEN_AUTO_SERVER"; then
      QWEN_SERVER_URL="http://127.0.0.1:8765"
    fi
    AUDIO="/tmp/tab-tts-$$-${RANDOM}.wav"
    QWEN_DEBUG_MODEL="${QWEN_MODEL:-Qwen/Qwen3-TTS-12Hz-1.7B-Base}"

    [ -x "$QWEN_PYTHON" ] || {
      echo "[$(date)] Qwen TTS unavailable: python not executable at $QWEN_PYTHON" >> "$LOG"
      return 1
    }
    [ -r "$QWEN_RUNNER" ] || {
      echo "[$(date)] Qwen TTS unavailable: runner not readable at $QWEN_RUNNER" >> "$LOG"
      return 1
    }
    if [ -r "$QWEN_VOICE/voice.json" ]; then
      QWEN_VOICE_ARGS=(--voice "$QWEN_VOICE")
    elif [ -r "$QWEN_VOICE/voicepack.json" ]; then
      QWEN_VOICE_ARGS=(--voicepack "$QWEN_VOICE")
    else
      echo "[$(date)] Qwen TTS unavailable: voice metadata missing at $QWEN_VOICE" >> "$LOG"
      return 1
    fi
    if [ -r "$QWEN_VOICE/voice.pt" ]; then
      :
    elif [ -r "$QWEN_VOICE/qwen_voice_prompt.pt" ]; then
      :
    else
      echo "[$(date)] Qwen TTS unavailable: voice prompt missing in $QWEN_VOICE" >> "$LOG"
      return 1
    fi

    SPOKEN_PHRASE=$(tts_phrase_for_model "$QWEN_DEBUG_MODEL" "$QWEN_VOICE")
    QWEN_ARGS=(
      "$QWEN_RUNNER"
      "${QWEN_VOICE_ARGS[@]}"
      --text "$SPOKEN_PHRASE"
      --output "$AUDIO"
    )
    [ -n "$QWEN_DEVICE" ] && QWEN_ARGS+=(--device "$QWEN_DEVICE")
    [ -n "$QWEN_DTYPE" ] && QWEN_ARGS+=(--dtype "$QWEN_DTYPE")
    [ -n "$QWEN_MODEL" ] && QWEN_ARGS+=(--model "$QWEN_MODEL")
    [ -n "$QWEN_SEED" ] && QWEN_ARGS+=(--seed "$QWEN_SEED")
    log_tts_debug "$QWEN_DEBUG_MODEL" "$QWEN_VOICE"

    qwen_server_healthy() {
      curl -fsS --max-time "${TAB_TTS_QWEN_SERVER_HEALTH_TIMEOUT_SEC:-0.8}" "${QWEN_SERVER_URL%/}/health" >/dev/null 2>&1
    }

    reclaim_wedged_qwen_server() {
      # A memory-starved server can keep holding the port without answering
      # /health. A fresh start then dies with "Address already in use" and the
      # wedged instance lingers, so every announcement falls through to `say`.
      # When the port is held but health is failing, kill the squatter so a
      # clean server can bind. Only ever runs after a failed health check.
      command -v lsof >/dev/null 2>&1 || return 0
      local port="$1" pids
      [ -n "$port" ] || return 0
      pids=$(lsof -ti "tcp:${port}" -sTCP:LISTEN 2>/dev/null)
      [ -n "$pids" ] || return 0
      echo "[$(date)] reclaiming wedged Qwen server on port $port (pids=$(echo $pids | tr '\n' ' '))" >> "$LOG"
      kill $pids 2>/dev/null
      for _ in 1 2 3 4 5 6; do
        lsof -ti "tcp:${port}" -sTCP:LISTEN >/dev/null 2>&1 || return 0
        sleep 0.5
      done
      pids=$(lsof -ti "tcp:${port}" -sTCP:LISTEN 2>/dev/null)
      [ -n "$pids" ] && kill -9 $pids 2>/dev/null
      sleep 0.5
    }

    start_qwen_server_if_needed() {
      [ -n "$QWEN_SERVER_URL" ] || return 1
      command -v curl >/dev/null || return 1

      if qwen_server_healthy; then
        return 0
      fi

      if tab_tts_falsey "$QWEN_AUTO_SERVER"; then
        echo "[$(date)] Qwen warm server not running and auto start is disabled (url=$QWEN_SERVER_URL)" >> "$LOG"
        return 1
      fi

      QWEN_SERVER_RUNNER="${TAB_TTS_QWEN_SERVER_RUNNER:-$(dirname "$QWEN_RUNNER")/serve.py}"
      [ -r "$QWEN_SERVER_RUNNER" ] || {
        echo "[$(date)] Qwen warm server unavailable: server runner not readable at $QWEN_SERVER_RUNNER" >> "$LOG"
        return 1
      }

      QWEN_SERVER_ENDPOINT="${QWEN_SERVER_URL#http://}"
      QWEN_SERVER_ENDPOINT="${QWEN_SERVER_ENDPOINT#https://}"
      QWEN_SERVER_ENDPOINT="${QWEN_SERVER_ENDPOINT%%/*}"
      QWEN_SERVER_HOST="${TAB_TTS_QWEN_SERVER_HOST:-${QWEN_SERVER_ENDPOINT%%:*}}"
      QWEN_SERVER_PORT="${TAB_TTS_QWEN_SERVER_PORT:-${QWEN_SERVER_ENDPOINT##*:}}"
      [ "$QWEN_SERVER_PORT" = "$QWEN_SERVER_HOST" ] && QWEN_SERVER_PORT=8765
      [ -n "$QWEN_SERVER_HOST" ] || QWEN_SERVER_HOST="127.0.0.1"
      QWEN_SERVER_LOG="${TAB_TTS_QWEN_SERVER_LOG:-/tmp/tab-tts-qwen-server.log}"
      QWEN_SERVER_PID="${TAB_TTS_QWEN_SERVER_PID:-/tmp/tab-tts-qwen-server.pid}"
      QWEN_SERVER_LOCK="${TAB_TTS_QWEN_SERVER_LOCK:-/tmp/tab-tts-qwen-server.lock}"
      QWEN_SERVER_IDLE_TIMEOUT="${TAB_TTS_QWEN_SERVER_IDLE_TIMEOUT_SEC:-300}"

      if mkdir "$QWEN_SERVER_LOCK" 2>/dev/null; then
        if ! qwen_server_healthy; then
          reclaim_wedged_qwen_server "$QWEN_SERVER_PORT"
          SERVER_ARGS=(
            "$QWEN_SERVER_RUNNER"
            --voice "$QWEN_VOICE"
            --host "$QWEN_SERVER_HOST"
            --port "$QWEN_SERVER_PORT"
            --idle-timeout "$QWEN_SERVER_IDLE_TIMEOUT"
          )
          [ -n "$QWEN_DEVICE" ] && SERVER_ARGS+=(--device "$QWEN_DEVICE")
          [ -n "$QWEN_DTYPE" ] && SERVER_ARGS+=(--dtype "$QWEN_DTYPE")
          [ -n "$QWEN_MODEL" ] && SERVER_ARGS+=(--model "$QWEN_MODEL")
          [ -n "$QWEN_SEED" ] && SERVER_ARGS+=(--seed "$QWEN_SEED")

          echo "[$(date)] starting Qwen warm server url=$QWEN_SERVER_URL runner=$QWEN_SERVER_RUNNER log=$QWEN_SERVER_LOG" >> "$LOG"
          nohup "$QWEN_PYTHON" "${SERVER_ARGS[@]}" >> "$QWEN_SERVER_LOG" 2>&1 &
          SERVER_PID=$!
          echo "$SERVER_PID" > "$QWEN_SERVER_PID"
          QWEN_SERVER_STARTED_THIS_RUN=1
        fi
        rmdir "$QWEN_SERVER_LOCK" 2>/dev/null
      else
        echo "[$(date)] Qwen warm server start already in progress" >> "$LOG"
      fi

      WAIT_START_MS=$(now_ms)
      WAIT_LIMIT="${TAB_TTS_QWEN_AUTO_START_TIMEOUT_SEC:-60}"
      for _ in $(seq 1 "$WAIT_LIMIT" 2>/dev/null || jot "$WAIT_LIMIT" 2>/dev/null); do
        if qwen_server_healthy; then
          WAIT_DONE_MS=$(now_ms)
          QWEN_SERVER_WAIT_MS=$((WAIT_DONE_MS - WAIT_START_MS))
          echo "[$(date)] Qwen warm server ready url=$QWEN_SERVER_URL wait_ms=$QWEN_SERVER_WAIT_MS started_this_run=$QWEN_SERVER_STARTED_THIS_RUN" >> "$LOG"
          return 0
        fi
        sleep 1
      done
      WAIT_DONE_MS=$(now_ms)
      QWEN_SERVER_WAIT_MS=$((WAIT_DONE_MS - WAIT_START_MS))
      echo "[$(date)] Qwen warm server not ready after ${QWEN_SERVER_WAIT_MS}ms, falling back to one-shot runner" >> "$LOG"
      return 1
    }

    if [ -n "$QWEN_SERVER_URL" ] && command -v jq >/dev/null && command -v curl >/dev/null && start_qwen_server_if_needed; then
      RESP_JSON="/tmp/tab-tts-qwen-server-$$-${RANDOM}.json"
      BODY=$(jq -nc \
        --arg voice "$QWEN_VOICE" \
        --arg text "$SPOKEN_PHRASE" \
        --arg output "$AUDIO" \
        --arg seed "$QWEN_SEED" \
        '{voice:$voice,text:$text,output:$output} + (if $seed != "" then {seed:($seed|tonumber)} else {} end)')
      TTS_START_MS=$(now_ms)
      HTTP=$(curl -sS --max-time "${TAB_TTS_QWEN_SERVER_TIMEOUT_SEC:-120}" -o "$RESP_JSON" -w '%{http_code}' \
        -X POST "${QWEN_SERVER_URL%/}/speak" \
        -H "Content-Type: application/json" \
        --data "$BODY" 2>>"$LOG")
      AUDIO_READY_MS=$(now_ms)
      if [ "$HTTP" = "200" ] && [ -s "$AUDIO" ]; then
        SERVER_MODEL=$(jq -r '.model // empty' "$RESP_JSON" 2>/dev/null)
        [ -n "$SERVER_MODEL" ] || SERVER_MODEL="$QWEN_DEBUG_MODEL"
        echo "[$(date)] tts_provider=qwen-server url=$QWEN_SERVER_URL voice=$QWEN_VOICE audio=$AUDIO" >> "$LOG"
        log_audio_ready "qwen-server" "$SERVER_MODEL" "$QWEN_VOICE" "$TTS_START_MS" "$AUDIO_READY_MS"
        afplay "$AUDIO" >>"$LOG" 2>&1
        PLAY_DONE_MS=$(now_ms)
        emit_timing "success" "qwen-server" "$SERVER_MODEL" "$QWEN_VOICE" "$AUDIO" "$HTTP" "$TTS_START_MS" "$AUDIO_READY_MS" "$PLAY_DONE_MS"
        rm -f "$AUDIO" "$RESP_JSON"
        return 0
      fi
      if [ "$HTTP" = "000" ]; then
        echo "[$(date)] Qwen server TTS timed out or disconnected (url=$QWEN_SERVER_URL), skipping one-shot Qwen fallback" >> "$LOG"
        emit_timing "failed" "qwen-server" "$QWEN_DEBUG_MODEL" "$QWEN_VOICE" "$AUDIO" "$HTTP" "$TTS_START_MS" "$AUDIO_READY_MS" "$AUDIO_READY_MS"
        rm -f "$AUDIO" "$RESP_JSON" 2>/dev/null
        return 1
      fi
      echo "[$(date)] Qwen server TTS failed (url=$QWEN_SERVER_URL http=$HTTP), falling back to runner" >> "$LOG"
      emit_timing "failed" "qwen-server" "$QWEN_DEBUG_MODEL" "$QWEN_VOICE" "$AUDIO" "$HTTP" "$TTS_START_MS" "$AUDIO_READY_MS" "$AUDIO_READY_MS"
      rm -f "$AUDIO" "$RESP_JSON" 2>/dev/null
    fi

    TTS_START_MS=$(now_ms)
    if "$QWEN_PYTHON" "${QWEN_ARGS[@]}" >>"$LOG" 2>&1 && [ -s "$AUDIO" ]; then
      AUDIO_READY_MS=$(now_ms)
      echo "[$(date)] tts_provider=qwen voice=$QWEN_VOICE audio=$AUDIO" >> "$LOG"
      log_audio_ready "qwen" "$QWEN_DEBUG_MODEL" "$QWEN_VOICE" "$TTS_START_MS" "$AUDIO_READY_MS"
      afplay "$AUDIO" >>"$LOG" 2>&1
      PLAY_DONE_MS=$(now_ms)
      emit_timing "success" "qwen" "$QWEN_DEBUG_MODEL" "$QWEN_VOICE" "$AUDIO" "" "$TTS_START_MS" "$AUDIO_READY_MS" "$PLAY_DONE_MS"
      rm -f "$AUDIO"
      return 0
    fi
    AUDIO_READY_MS=$(now_ms)
    echo "[$(date)] Qwen TTS failed" >> "$LOG"
    emit_timing "failed" "qwen" "$QWEN_DEBUG_MODEL" "$QWEN_VOICE" "$AUDIO" "" "$TTS_START_MS" "$AUDIO_READY_MS" "$AUDIO_READY_MS"
    rm -f "$AUDIO" 2>/dev/null
    return 1
  }

  play_say_tts() {
    log_tts_debug "macos-say" "system-voice"
    echo "[$(date)] tts_provider=say" >> "$LOG"
    TTS_START_MS=$(now_ms)
    AUDIO_READY_MS="$TTS_START_MS"
    log_audio_ready "say" "macos-say" "system-voice" "$TTS_START_MS" "$AUDIO_READY_MS"
    # Default the last-resort macOS voice to a female one (Samantha) so a
    # fallback never surfaces as a jarring male system voice. Override with
    # TAB_TTS_SAY_VOICE; falls back to the system default if it isn't installed.
    SAY_VOICE="${TAB_TTS_SAY_VOICE:-Samantha}"
    SAY_VOICE_ARGS=()
    if [ -n "$SAY_VOICE" ] && say -v '?' 2>/dev/null | grep -qi "^${SAY_VOICE}[[:space:]]"; then
      SAY_VOICE_ARGS=(-v "$SAY_VOICE")
    fi
    say "${SAY_VOICE_ARGS[@]}" "$(tts_phrase_for_model "macos-say" "system-voice")" >>"$LOG" 2>&1
    PLAY_DONE_MS=$(now_ms)
    emit_timing "success" "say" "macos-say" "system-voice" "" "" "$TTS_START_MS" "$AUDIO_READY_MS" "$PLAY_DONE_MS"
  }

  play_tts_provider() {
    case "$(normalize_tts_provider "$1")" in
      qwen|qwen3|local-qwen) play_qwen_tts ;;
      elevenlabs|eleven-labs) play_elevenlabs_tts ;;
      openai) play_openai_tts ;;
      say|macos|system) play_say_tts ;;
      auto)
        play_elevenlabs_tts || play_openai_tts || play_say_tts
        ;;
      *)
        echo "[$(date)] Unknown TAB_TTS_PROVIDER=$1, using auto" >> "$LOG"
        play_elevenlabs_tts || play_openai_tts || play_say_tts
        ;;
    esac
  }

  if ! play_tts_provider "$PRIMARY_PROVIDER"; then
    if [ "$FALLBACK_PROVIDER" != "$PRIMARY_PROVIDER" ]; then
      echo "[$(date)] primary TTS provider failed ($PRIMARY_PROVIDER), trying fallback=$FALLBACK_PROVIDER" >> "$LOG"
      play_tts_provider "$FALLBACK_PROVIDER" || play_say_tts
    else
      play_say_tts
    fi
  fi
) </dev/null >/dev/null 2>&1 &

exit 0
