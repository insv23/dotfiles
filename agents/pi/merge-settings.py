#!/usr/bin/env python3
"""Move portable Pi settings between the live file and the repo file.

Default: repo → live (used by ./install).
--export: live → repo, dropping machine-only keys.

The live file stays a regular file so model switches do not dirty git.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

LIVE_PATH = Path.home() / ".pi/agent/settings.json"
REPO_PATH = Path(__file__).resolve().parent / "settings.json"

# Pi writes these locally, or they intentionally point at local-only resources.
# Never copy them to or from git-managed settings.
LOCAL_ONLY_KEYS = {
    "lastChangelogVersion",
    "defaultProvider",
    "defaultModel",
    "defaultThinkingLevel",
    "enabledModels",
    "skills",
}


def load_json(path: Path) -> dict:
    return json.loads(path.read_text())


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n")


def portable_keys(data: dict) -> dict:
    return {key: value for key, value in data.items() if key not in LOCAL_ONLY_KEYS}


def portable_from_repo() -> dict:
    return portable_keys(load_json(REPO_PATH))


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


def export_repo() -> dict:
    if not LIVE_PATH.exists() and not LIVE_PATH.is_symlink():
        raise SystemExit(f"missing live settings: {LIVE_PATH}")
    portable = portable_keys(load_json(LIVE_PATH))
    dump_json(REPO_PATH, portable)
    return portable


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--export",
        action="store_true",
        help="write portable keys from the live file into the repo file",
    )
    args = parser.parse_args()
    if args.export:
        portable = export_repo()
        print(f"exported {len(portable)} portable keys to {REPO_PATH}")
        print("packages:", ", ".join(portable.get("packages", [])))
    else:
        merged = merge_live()
        print(f"merged {len(portable_from_repo())} portable keys into {LIVE_PATH}")
        print("packages:", ", ".join(merged.get("packages", [])))
