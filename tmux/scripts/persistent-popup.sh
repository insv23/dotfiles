#!/usr/bin/env bash
# 持久化 tmux popup：按外层 session + window_id 隔离；在 popup 内再次触发则 detach 当前 popup。

set -euo pipefail

session_name="${1:-}"
window_id="${2:-}"
pane_path="${3:-$HOME}"
client_tty="${4:-}"

if [[ "$session_name" == popup-* ]]; then
  if [[ -n "$client_tty" ]]; then
    tmux detach-client -t "$client_tty"
  else
    tmux detach-client
  fi
  exit 0
fi

safe_session_name=$(printf "%s" "$session_name" | tr -cs '[:alnum:]_.-' '_')
safe_window_id=$(printf "%s" "${window_id#@}" | tr -cs '[:alnum:]_.-' '_')
popup_name="popup-${safe_session_name}-${safe_window_id}"

tmux display-popup \
  -E \
  -w 90% \
  -h 90% \
  -d "$pane_path" \
  tmux new-session -A -s "$popup_name" -c "$pane_path"
