#!/bin/sh

case "$1:$(hostname -s)" in
  power:macmini)
    exec "$HOME/.config/herdr/mac-power.py"
    ;;
  codex:mba)
    exec "$HOME/.config/herdr/codex-usage.py"
    ;;
  power:* | codex:*)
    exit 0
    ;;
  *)
    exit 2
    ;;
esac
