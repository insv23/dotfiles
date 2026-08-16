---
name: export-pi-settings
description: Copy portable keys from ~/.pi/agent/settings.json into ~/.dotfiles/agents/pi/settings.json. Use when the user asks to export Pi settings, sync settings to dotfiles, persist /settings or packages, or 同步设置.
---

# Export Pi Settings

One-way: live file → repo file. Drops machine-only keys.

- Live: `~/.pi/agent/settings.json`
- Repo: `~/.dotfiles/agents/pi/settings.json`
- Dropped: `defaultProvider`, `defaultModel`, `defaultThinkingLevel`, `enabledModels`, `lastChangelogVersion`
- This machine: no `./install`
- Other machines: `git pull` then `./install`

## Steps

1. **Export**

   ```bash
   python3 ~/.dotfiles/agents/pi/merge-settings.py --export
   ```

   Done when the command exits 0.
2. **Changelog** `~/.dotfiles/CHANGELOG.md` under today's `### Pi` heading (create the date/`Pi` headers if missing), Chinese, one bullet: which portable keys changed and why. Done when the bullet exists, or when `git diff -- ~/.dotfiles/agents/pi/settings.json` is empty (then skip the bullet).
3. **Report** that this machine needs no `./install`, and that git commit/push is what other machines need. Skip commit unless the user asked.
