#!/bin/sh

# Herdr runs one tab-bar entry per data source, so this script only maps the
# requested source to the host that can read it. Codex usage is paused: no entry
# calls codex-usage.py. A host/source pair without a match prints nothing, and
# Herdr clears entries with empty output.
#
# The sibling scripts are referenced from this script's own directory, so adding
# a script here needs no config.yaml entry and no symlink in ~/.config/herdr.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

case "$(hostname -s):$1" in
  macmini:power)
    exec "$SCRIPT_DIR/mac-power.py"
    ;;
  mba:commandcode)
    exec "$SCRIPT_DIR/commandcode-usage.py"
    ;;
  *)
    exit 0
    ;;
esac
