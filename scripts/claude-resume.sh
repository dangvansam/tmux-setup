#!/usr/bin/env bash
set -uo pipefail

MAP_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect/claude-sessions.tsv"
PROJECTS_DIR="$HOME/.claude/projects"

pane_key() {
  tmux display-message -p -t "${TMUX_PANE:-}" '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null
}

lookup_session_id() {
  [ -f "$MAP_FILE" ] || return 0
  awk -F'\t' -v key="$1" '$1 == key {print $2; exit}' "$MAP_FILE"
}

transcript_exists() {
  compgen -G "$PROJECTS_DIR/*/$1.jsonl" >/dev/null
}

resolve_command() {
  local sid
  sid="$(lookup_session_id "$(pane_key)")"
  if [ -z "$sid" ]; then
    echo "claude --continue"
  elif transcript_exists "$sid"; then
    echo "claude --resume $sid"
  else
    echo "claude"
  fi
}

main() {
  local cmd
  cmd="$(resolve_command)"
  if [ "${1:-}" = "--print" ]; then
    echo "$cmd"
    return 0
  fi
  exec $cmd
}

main "$@"
