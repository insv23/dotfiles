#!/bin/sh

# Herdr runs one tab-bar entry per data source, so this script only maps the
# requested source to the host that can read it. Codex usage is paused: no entry
# calls codex-usage.py. A host/source pair without a match prints nothing, and
# Herdr clears entries with empty output.
case "$(hostname -s):$1" in
  macmini:power)
    exec "$HOME/.config/herdr/mac-power.py"
    ;;
  mba:commandcode)
    exec "$HOME/.config/herdr/commandcode-usage.py"
    ;;
  *)
    exit 0
    ;;
esac
