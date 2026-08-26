#!/bin/sh

case "$(hostname -s)" in
  macmini)
    exec "$HOME/.config/herdr/mac-power.py"
    ;;
  *)
    exec "$HOME/.config/herdr/codex-usage.py"
    ;;
esac
