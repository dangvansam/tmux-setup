#!/usr/bin/env bash
set -uo pipefail

STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
MAP_FILE="$STATE_DIR/claude-sessions.tsv"
SESSIONS_DIR="$HOME/.claude/sessions"

read_session_field() {
  local file="$1"
  local field="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg f "$field" '.[$f] // empty' "$file" 2>/dev/null
    return
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get(sys.argv[2], ""))' "$file" "$field" 2>/dev/null
    return
  fi
  grep -o "\"$field\":\"[^\"]*\"" "$file" | head -1 | cut -d'"' -f4
}

claude_pids_on_tty() {
  ps -t "${1#/dev/}" -o pid=,comm= 2>/dev/null | awk '$2 == "claude" {print $1}'
}

session_id_for_pane() {
  local tty="$1"
  local pane_path="$2"
  local pid file cwd
  for pid in $(claude_pids_on_tty "$tty"); do
    file="$SESSIONS_DIR/$pid.json"
    [ -f "$file" ] || continue
    cwd="$(read_session_field "$file" cwd)"
    [ "$cwd" = "$pane_path" ] || continue
    read_session_field "$file" sessionId
    return 0
  done
  return 1
}

main() {
  mkdir -p "$STATE_DIR"
  local tmp key tty pane_path sid
  tmp="$(mktemp "$MAP_FILE.XXXXXX")"
  tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}	#{pane_tty}	#{pane_current_path}" |
    while IFS=$'\t' read -r key tty pane_path; do
      sid="$(session_id_for_pane "$tty" "$pane_path")" || continue
      [ -n "$sid" ] && printf '%s\t%s\n' "$key" "$sid"
    done > "$tmp"
  mv "$tmp" "$MAP_FILE"
}

main "$@"
