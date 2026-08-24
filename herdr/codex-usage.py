#!/usr/bin/env python3
"""Print current Codex weekly subscription quota for Herdr's tab bar."""

from datetime import datetime
import json
import math
from pathlib import Path
import selectors
import shutil
import subprocess
import tempfile
import time
from typing import Any, Optional


CACHE_PATH = Path.home() / ".cache" / "herdr" / "codex-usage.json"
DIAGNOSTIC_PATH = CACHE_PATH.with_name("codex-usage-error.json")
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


def display(left: float, reset_at: float, prefix: str = "") -> str:
    reset = datetime.fromtimestamp(reset_at).astimezone()
    return f"{prefix}Codex {left:.0f}% left・Reset at {reset:%m/%d %H:%M}"


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


def cached_usage() -> tuple[float, float, float]:
    cached = json.loads(CACHE_PATH.read_text())
    if not isinstance(cached, dict):
        raise ValueError
    left = float(cached["left"])
    reset_at = float(cached["reset_at"])
    updated_at = float(cached.get("updated_at", CACHE_PATH.stat().st_mtime))
    if (
        not 0 <= left <= 100
        or reset_at <= 0
        or updated_at <= 0
        or not all(math.isfinite(value) for value in (left, reset_at, updated_at))
    ):
        raise ValueError
    datetime.fromtimestamp(reset_at)
    datetime.fromtimestamp(updated_at)
    return left, reset_at, updated_at


def save_usage(left: float, reset_at: float) -> None:
    atomic_write(
        CACHE_PATH,
        json.dumps({"left": left, "reset_at": reset_at, "updated_at": time.time()}),
    )


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


def read_usage(codex_path: str) -> tuple[float, float]:
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
        windows = (limits.get("primary"), limits.get("secondary"))
        weekly = next(
            (
                window
                for window in windows
                if isinstance(window, dict)
                and window.get("windowDurationMins") == WEEK_MINUTES
            ),
            None,
        )
        if weekly is None:
            raise ProviderError("Invalid response")
        used_percent = float(weekly["usedPercent"])
        reset_at = float(weekly["resetsAt"])
        if not 0 <= used_percent <= 100 or reset_at <= 0:
            raise ValueError
        if not all(math.isfinite(value) for value in (used_percent, reset_at)):
            raise ValueError
        datetime.fromtimestamp(reset_at)
        return 100 - used_percent, reset_at
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
    except (OSError, TypeError, ValueError, OverflowError, json.JSONDecodeError):
        cached = None
    try:
        record_error(error)
    except OSError:
        pass
    if cached is not None:
        updated = datetime.fromtimestamp(cached[2]).astimezone()
        prefix = f"({error.reason}・Last updated at {updated:%m/%d %H:%M}) "
        print(display(cached[0], cached[1], prefix))
    else:
        print(f"Codex --・{error.reason}")


def main() -> None:
    codex_path = shutil.which("codex")
    if codex_path is None:
        render_failure(ProviderError("Codex CLI not found"))
        return
    try:
        left, reset_at = read_usage(codex_path)
    except ProviderError as error:
        render_failure(error)
        return
    try:
        save_usage(left, reset_at)
        clear_error()
    except OSError:
        pass
    print(display(left, reset_at))


if __name__ == "__main__":
    main()
