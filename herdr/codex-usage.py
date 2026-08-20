#!/usr/bin/env python3
"""Print current Codex weekly subscription quota for Herdr's tab bar."""

from datetime import datetime
import json
from pathlib import Path
from typing import Optional
from urllib.request import Request, urlopen


AUTH_PATH = Path.home() / ".codex" / "auth.json"
CACHE_PATH = Path.home() / ".cache" / "herdr" / "codex-usage.json"
USAGE_URL = "https://chatgpt.com/backend-api/wham/usage"
WEEK_SECONDS = 7 * 24 * 60 * 60


def display(left: float, reset_at: float, prefix: str = "") -> str:
    reset = datetime.fromtimestamp(reset_at).astimezone()
    return f"{prefix}Codex {left:.0f}% left・Reset at {reset:%m/%d %H:%M}"


def cached_usage() -> Optional[tuple[float, float]]:
    try:
        cached = json.loads(CACHE_PATH.read_text())
        return float(cached["left"]), float(cached["reset_at"])
    except (KeyError, OSError, TypeError, ValueError):
        return None


def save_usage(left: float, reset_at: float) -> None:
    CACHE_PATH.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    temporary_path = CACHE_PATH.with_name(f".{CACHE_PATH.name}.tmp")
    temporary_path.write_text(json.dumps({"left": left, "reset_at": reset_at}))
    temporary_path.chmod(0o600)
    temporary_path.replace(CACHE_PATH)


def main() -> None:
    try:
        tokens = json.loads(AUTH_PATH.read_text())["tokens"]
        request = Request(
            USAGE_URL,
            headers={
                "Authorization": f"Bearer {tokens['access_token']}",
                "ChatGPT-Account-Id": tokens["account_id"],
                "Accept": "application/json",
                "User-Agent": "codex-cli",
            },
        )
        with urlopen(request, timeout=5) as response:
            payload = json.load(response)
        windows = payload.get("rate_limit", {})
        weekly = next(
            window
            for window in (windows.get("primary_window"), windows.get("secondary_window"))
            if window and window.get("limit_window_seconds") == WEEK_SECONDS
        )
        left = 100 - weekly["used_percent"]
        reset_at = weekly["reset_at"]
        save_usage(left, reset_at)
        print(display(left, reset_at))
    except (KeyError, OSError, StopIteration, TypeError, ValueError):
        cached = cached_usage()
        print(display(*cached, prefix="?") if cached else "?Codex --")


if __name__ == "__main__":
    main()
