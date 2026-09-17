#!/bin/sh

status_dir="$HOME/.cache/herdr"
usage_state="$status_dir/usage-display"

case "$1:$(hostname -s)" in
  power:macmini)
    exec "$HOME/.config/herdr/mac-power.py"
    ;;
  codex:mba)
    # Each Herdr call is a new process, so the previous choice lives in a file.
    next=codex
    if [ -r "$usage_state" ]; then
      read -r last <"$usage_state" || last=""
      case "$last" in
        codex) next=commandcode ;;
        commandcode) next=codex ;;
      esac
    fi
    mkdir -p "$status_dir" 2>/dev/null
    printf '%s\n' "$next" >"$usage_state" 2>/dev/null
    case "$next" in
      codex) exec "$HOME/.config/herdr/codex-usage.py" ;;
      *) exec "$HOME/.config/herdr/commandcode-usage.py" ;;
    esac
    ;;
  power:* | codex:*)
    exit 0
    ;;
  *)
    exit 2
    ;;
esac
