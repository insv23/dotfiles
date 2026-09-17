#!/usr/bin/env python3
"""Print current Codex subscription quotas for Herdr's tab bar."""

from datetime import datetime
import json
import math
from pathlib import Path
import selectors
import shutil
import sqlite3
import subprocess
import tempfile
import time
from typing import Any, Optional


STATE_DIR = Path.home() / ".cache" / "herdr"
DIAGNOSTIC_PATH = STATE_DIR / "codex-usage-error.json"
DB_PATH = STATE_DIR / "codex-usage.db"
DB_SCHEMA = """
CREATE TABLE IF NOT EXISTS usage_samples (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sampled_at REAL NOT NULL,
    plan TEXT,
    five_hour_left REAL,
    five_hour_reset_at REAL,
    weekly_left REAL,
    weekly_reset_at REAL
)
"""
DB_INDEX = (
    "CREATE INDEX IF NOT EXISTS usage_samples_sampled_at ON usage_samples (sampled_at)"
)
SAMPLE_FIELDS = (
    "plan",
    "five_hour_left",
    "five_hour_reset_at",
    "weekly_left",
    "weekly_reset_at",
)
FIVE_HOUR_MINUTES = 5 * 60
WEEK_MINUTES = 7 * 24 * 60
TOTAL_TIMEOUT = 8.0
TERMINATE_GRACE = 0.25


class ProviderError(Exception):
    def __init__(
        self,
        reason: str,
        rpc_code: Optional[int] = None,
        exit_code: Optional[int] = None,
        exception: Optional[str] = None,
    ) -> None:
        super().__init__(reason)
        self.reason = reason
        self.rpc_code = rpc_code
        self.exit_code = exit_code
        self.exception = exception


def display(usage: dict[str, Any], prefix: str = "") -> str:
    label = "Codex Free:" if usage.get("plan") == "free" else "Codex:"
    parts = []
    for name, window in (("5H", usage.get("five_hour")), ("Week", usage.get("week"))):
        if window is None:
            continue
        reset = datetime.fromtimestamp(window["reset_at"]).astimezone()
        reset_format = "%H:%M" if name == "5H" else "%m/%d %H:%M"
        parts.append(
            f"{name} {window['left']:.0f}% left・Reset at {reset:{reset_format}}"
        )
    return f"{prefix}{label} {' | '.join(parts)}"


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    temporary_path: Optional[Path] = None
    try:
        with tempfile.NamedTemporaryFile(
            "w", dir=path.parent, prefix=f".{path.name}.", delete=False
        ) as temporary_file:
            temporary_file.write(content)
            temporary_path = Path(temporary_file.name)
        temporary_path.chmod(0o600)
        temporary_path.replace(path)
    except OSError:
        if temporary_path is not None:
            try:
                temporary_path.unlink()
            except OSError:
                pass
        raise


def validate_window(window: Any) -> Optional[dict[str, float]]:
    if not isinstance(window, dict):
        return None
    used_percent = float(window["usedPercent"])
    reset_at = float(window["resetsAt"])
    if not 0 <= used_percent <= 100 or reset_at <= 0:
        raise ValueError
    if not all(math.isfinite(value) for value in (used_percent, reset_at)):
        raise ValueError
    datetime.fromtimestamp(reset_at)
    return {"left": 100 - used_percent, "reset_at": reset_at}


def record_sample(usage: dict[str, Any], sampled_at: float) -> None:
    """Store a Codex usage sample only when a measured value changed."""
    five_hour = usage.get("five_hour") or {}
    week = usage.get("week") or {}
    row = (
        sampled_at,
        usage.get("plan"),
        five_hour.get("left"),
        five_hour.get("reset_at"),
        week.get("left"),
        week.get("reset_at"),
    )
    DB_PATH.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    connection = sqlite3.connect(DB_PATH, timeout=2.0)
    try:
        connection.execute(DB_SCHEMA)
        connection.execute(DB_INDEX)
        last = connection.execute(
            "SELECT " + ", ".join(SAMPLE_FIELDS)
            + " FROM usage_samples ORDER BY id DESC LIMIT 1"
        ).fetchone()
        if last is None or tuple(last) != row[1:]:
            connection.execute(
                "INSERT INTO usage_samples (sampled_at, "
                + ", ".join(SAMPLE_FIELDS)
                + ") VALUES (?, ?, ?, ?, ?, ?)",
                row,
            )
            connection.commit()
    finally:
        connection.close()


def cached_usage() -> tuple[dict[str, Any], float]:
    connection = sqlite3.connect(DB_PATH, timeout=2.0)
    try:
        row = connection.execute(
            "SELECT sampled_at, " + ", ".join(SAMPLE_FIELDS)
            + " FROM usage_samples ORDER BY id DESC LIMIT 1"
        ).fetchone()
    finally:
        connection.close()
    if row is None:
        raise ValueError
    updated_at, plan, five_left, five_reset, week_left, week_reset = row
    updated_at = float(updated_at)
    if updated_at <= 0 or not math.isfinite(updated_at):
        raise ValueError
    datetime.fromtimestamp(updated_at)
    usage: dict[str, Any] = {"plan": plan}
    for name, left, reset_at in (
        ("five_hour", five_left, five_reset),
        ("week", week_left, week_reset),
    ):
        if left is None or reset_at is None:
            continue
        left = float(left)
        reset_at = float(reset_at)
        if not 0 <= left <= 100 or reset_at <= 0:
            raise ValueError
        if not all(math.isfinite(value) for value in (left, reset_at)):
            raise ValueError
        datetime.fromtimestamp(reset_at)
        usage[name] = {"left": left, "reset_at": reset_at}
    if not any(usage.get(name) for name in ("five_hour", "week")):
        raise ValueError
    return usage, updated_at


def record_error(error: ProviderError) -> None:
    payload: dict[str, Any] = {
        "timestamp": datetime.now().astimezone().isoformat(),
        "category": error.reason,
    }
    if error.rpc_code is not None:
        payload["rpc_code"] = error.rpc_code
    if error.exit_code is not None:
        payload["exit_code"] = error.exit_code
    if error.exception is not None:
        payload["exception"] = error.exception
    atomic_write(DIAGNOSTIC_PATH, json.dumps(payload))


def clear_error() -> None:
    try:
        DIAGNOSTIC_PATH.unlink()
    except OSError:
        pass


def send_message(process: subprocess.Popen[bytes], message: dict[str, Any]) -> None:
    try:
        assert process.stdin is not None
        process.stdin.write((json.dumps(message) + "\n").encode())
        process.stdin.flush()
    except (BrokenPipeError, OSError) as error:
        raise ProviderError("Codex CLI error", exception=type(error).__name__) from error


def read_response(
    process: subprocess.Popen[bytes],
    selector: selectors.BaseSelector,
    request_id: int,
    deadline: float,
) -> dict[str, Any]:
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise ProviderError("Timeout")
        events = selector.select(remaining)
        if not events:
            raise ProviderError("Timeout")
        try:
            assert process.stdout is not None
            line = process.stdout.readline()
        except OSError as error:
            raise ProviderError("Codex CLI error", exception=type(error).__name__) from error
        if not line:
            exit_code = process.poll()
            raise ProviderError(
                "Codex CLI error",
                exit_code=exit_code,
            )
        try:
            message = json.loads(line)
        except json.JSONDecodeError as error:
            raise ProviderError("Invalid response") from error
        if not isinstance(message, dict):
            raise ProviderError("Invalid response")
        if message.get("id") != request_id:
            continue
        if "error" in message:
            error = message["error"]
            if not isinstance(error, dict):
                raise ProviderError("Codex error")
            code = error.get("code")
            if code == -32601:
                raise ProviderError("Update Codex CLI", rpc_code=code)
            if code == -32001:
                raise ProviderError("Codex busy", rpc_code=code)
            raise ProviderError(
                "Codex error", rpc_code=code if isinstance(code, int) else None
            )
        result = message.get("result")
        if not isinstance(result, dict):
            raise ProviderError("Invalid response")
        return result


def stop_process(process: subprocess.Popen[bytes]) -> None:
    try:
        if process.stdin is not None:
            process.stdin.close()
    except OSError:
        pass
    try:
        if process.poll() is None:
            process.terminate()
        process.wait(timeout=TERMINATE_GRACE)
        return
    except (OSError, subprocess.TimeoutExpired):
        pass
    try:
        process.kill()
        process.wait(timeout=TERMINATE_GRACE)
    except (OSError, subprocess.TimeoutExpired):
        pass


def read_usage(codex_path: str) -> dict[str, Any]:
    try:
        process = subprocess.Popen(
            [codex_path, "app-server", "--stdio"],
            shell=False,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            bufsize=0,
        )
    except (OSError, ValueError) as error:
        raise ProviderError("Codex CLI error", exception=type(error).__name__) from error

    selector = selectors.DefaultSelector()
    try:
        assert process.stdout is not None
        selector.register(process.stdout, selectors.EVENT_READ)
        deadline = time.monotonic() + TOTAL_TIMEOUT
        send_message(
            process,
            {
                "method": "initialize",
                "id": 0,
                "params": {
                    "clientInfo": {
                        "name": "herdr_codex_usage",
                        "title": "Herdr Codex Usage",
                        "version": "1",
                    }
                },
            },
        )
        read_response(process, selector, 0, deadline)
        send_message(process, {"method": "initialized", "params": {}})
        send_message(
            process,
            {"method": "account/read", "id": 1, "params": {"refreshToken": False}},
        )
        account_result = read_response(process, selector, 1, deadline)
        account = account_result.get("account")
        if not isinstance(account, dict) or account.get("type") not in {
            "chatgpt",
            "personalAccessToken",
        }:
            raise ProviderError("Run codex login")
        send_message(process, {"method": "account/rateLimits/read", "id": 2})
        limits_result = read_response(process, selector, 2, deadline)
        limits = limits_result.get("rateLimits")
        if not isinstance(limits, dict):
            raise ProviderError("Invalid response")
        plan = (
            account.get("planType")
            or account_result.get("planType")
            or limits_result.get("planType")
            or limits.get("planType")
        )
        usage: dict[str, Any] = {"plan": plan}
        for window in (limits.get("primary"), limits.get("secondary")):
            if not isinstance(window, dict):
                continue
            duration = window.get("windowDurationMins")
            name = {FIVE_HOUR_MINUTES: "five_hour", WEEK_MINUTES: "week"}.get(duration)
            if name is not None and name not in usage:
                usage[name] = validate_window(window)
        if not any(usage.get(name) for name in ("five_hour", "week")):
            raise ProviderError("Invalid response")
        return usage
    except ProviderError:
        raise
    except (KeyError, TypeError, ValueError, OverflowError, OSError) as error:
        raise ProviderError("Invalid response", exception=type(error).__name__) from error
    finally:
        selector.close()
        stop_process(process)


def render_failure(error: ProviderError) -> None:
    try:
        cached = cached_usage()
    except (OSError, TypeError, ValueError, OverflowError, sqlite3.Error):
        cached = None
    try:
        record_error(error)
    except OSError:
        pass
    if cached is not None:
        usage, updated_at = cached
        updated = datetime.fromtimestamp(updated_at).astimezone()
        prefix = f"({error.reason}・Last updated at {updated:%m/%d %H:%M}) "
        print(display(usage, prefix))
    else:
        print(f"Codex --・{error.reason}")


def main() -> None:
    codex_path = shutil.which("codex")
    if codex_path is None:
        render_failure(ProviderError("Codex CLI not found"))
        return
    try:
        usage = read_usage(codex_path)
    except ProviderError as error:
        render_failure(error)
        return
    try:
        record_sample(usage, time.time())
        clear_error()
    except (OSError, sqlite3.Error):
        pass
    print(display(usage))


if __name__ == "__main__":
    main()
