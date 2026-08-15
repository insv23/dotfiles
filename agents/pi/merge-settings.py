#!/usr/bin/env python3
"""Merge portable Pi settings into the live ~/.pi/agent/settings.json.

The live file stays a regular file so model switches do not dirty git.
Repo settings.json is the source of truth for packages and shared UI keys.
"""

from __future__ import annotations

import json
from pathlib import Path

LIVE_PATH = Path.home() / ".pi/agent/settings.json"
REPO_PATH = Path(__file__).resolve().parent / "settings.json"

# Pi writes these on model / changelog changes. Never copy them from git.
MACHINE_KEYS = {
    "lastChangelogVersion",
    "defaultProvider",
    "defaultModel",
    "defaultThinkingLevel",
    "enabledModels",
}


def load_json(path: Path) -> dict:
    return json.loads(path.read_text())


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n")


def portable_from_repo() -> dict:
    data = load_json(REPO_PATH)
    return {key: value for key, value in data.items() if key not in MACHINE_KEYS}


def merge_live() -> dict:
    portable = portable_from_repo()
    live: dict = {}
    if LIVE_PATH.exists() or LIVE_PATH.is_symlink():
        live = load_json(LIVE_PATH)
    live.update(portable)
    if LIVE_PATH.is_symlink() or LIVE_PATH.is_file():
        LIVE_PATH.unlink()
    dump_json(LIVE_PATH, live)
    return live


if __name__ == "__main__":
    merged = merge_live()
    print(f"merged {len(portable_from_repo())} portable keys into {LIVE_PATH}")
    print("packages:", ", ".join(merged.get("packages", [])))
