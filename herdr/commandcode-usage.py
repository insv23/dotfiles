#!/usr/bin/env python3
"""Print current Command Code subscription usage for Herdr's tab bar."""

from datetime import datetime, timezone
import argparse
import json
import math
import os
from pathlib import Path
import re
import sqlite3
import tempfile
import time
from typing import Any, Optional
import urllib.error
import urllib.request


STATE_DIR = Path.home() / ".cache" / "herdr"
DIAGNOSTIC_PATH = STATE_DIR / "commandcode-usage-error.json"
DB_PATH = STATE_DIR / "commandcode-usage.db"
DB_SCHEMA = """
CREATE TABLE IF NOT EXISTS usage_samples (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sampled_at REAL NOT NULL,
    plan TEXT,
    five_hour_used REAL,
    five_hour_cap REAL,
    five_hour_reset_at REAL,
    weekly_used REAL,
    weekly_cap REAL,
    weekly_reset_at REAL,
    month_used REAL,
    quota REAL,
    period_end REAL,
    requests INTEGER,
    average_cost REAL
)
"""
DB_INDEX = (
    "CREATE INDEX IF NOT EXISTS usage_samples_sampled_at ON usage_samples (sampled_at)"
)
# Every column except the timestamp decides whether a sample is a repeat.
SAMPLE_FIELDS = (
    "plan",
    "five_hour_used",
    "five_hour_cap",
    "five_hour_reset_at",
    "weekly_used",
    "weekly_cap",
    "weekly_reset_at",
    "month_used",
    "quota",
    "period_end",
    "requests",
    "average_cost",
)
MIGRATION_COLUMNS = {
    "five_hour_cap": "REAL",
    "five_hour_reset_at": "REAL",
    "weekly_cap": "REAL",
    "weekly_reset_at": "REAL",
    "period_end": "REAL",
}
API_BASE = "https://api.commandcode.ai"
CREDITS_ENDPOINT = "/alpha/billing/credits"
SUBSCRIPTIONS_ENDPOINT = "/alpha/billing/subscriptions"
SUMMARY_ENDPOINT = "/alpha/usage/summary"
API_KEY_ENV = "PI_COMMAND_CODE_KEY"
SECRET_PATH = Path.home() / ".dotfiles" / "zsh" / "hosts"
TOTAL_TIMEOUT = 8.0
SECONDS_PER_DAY = 86400
# The billing period end only moves once per cycle, so a cached copy stays
# usable for a day without another round trip.
PLAN_CACHE_TTL = 24 * 3600
# The API rejects python-urllib's default User-Agent with 403.
USER_AGENT = "commandcode-usage.py"
PLAN_LABELS = {
    "individual-go": "Go",
    "individual-goat": "GOAT",
    "individual-pro": "Pro",
    "individual-pro-v1": "Pro",
    "individual-provider": "Provider",
    "individual-max": "Max",
    "individual-ultra": "Ultra",
    "teams-pro": "Teams Pro",
}


class ProviderError(Exception):
    def __init__(self, reason: str, exception: Optional[str] = None) -> None:
        super().__init__(reason)
        self.reason = reason
        self.exception = exception


def format_money(value: float) -> str:
    return f"${value:.3f}"


def format_average(value: float) -> str:
    return f"${value:.4f}"


def format_quota(value: float) -> str:
    # The derived monthly quota lands a fraction off the round plan value because
    # usage and balance are read at slightly different moments.
    return f"{round(value):.0f}"


def format_cap(value: float) -> str:
    return f"{round(value):.0f}" if value == round(value) else f"{value:.2f}"


def format_countdown(seconds: float) -> str:
    if seconds <= 0:
        return "now"
    hours = seconds / 3600
    if hours < 24:
        return f"{hours:.1f}h"
    days = int(seconds // SECONDS_PER_DAY)
    return f"{days}d{int((seconds % SECONDS_PER_DAY) // 3600)}h"


def format_reset(reset_at: float) -> str:
    return datetime.fromtimestamp(reset_at).astimezone().strftime("%m-%d %H:%M")


def format_window(window: dict[str, float], now: float) -> str:
    text = f"{format_money(window['used'])}/{format_cap(window['cap'])}"
    reset_at = window.get("reset_at")
    if reset_at:
        text = f"{text} ↻{format_countdown(reset_at - now)}"
    return text


def display(usage: dict[str, Any], prefix: str = "") -> str:
    now = time.time()
    parts = []
    for window in (usage.get("five_hour"), usage.get("week")):
        if window is not None:
            parts.append(format_window(window, now))
    month_used = usage.get("month_used")
    quota = usage.get("quota")
    if month_used is not None and quota is not None:
        text = f"{format_money(month_used)}/{format_quota(quota)}"
        period_end = usage.get("period_end")
        if period_end:
            text = f"{text} ↻{format_reset(period_end)}"
        parts.append(text)
    body = " | ".join(parts)
    requests = usage.get("requests")
    if requests is not None:
        tail = f"{int(requests)} req"
        average = usage.get("average")
        if average is not None:
            tail = f"{tail}({format_average(average)})"
        body = f"{body} | {tail}" if body else tail
    return f"{prefix}{body}"


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


def read_api_key() -> Optional[str]:
    key = os.environ.get(API_KEY_ENV)
    if key:
        return key.strip()
    secret_path = SECRET_PATH / f"{os.uname().nodename.split('.')[0]}.zshenv.secret"
    try:
        content = secret_path.read_text()
    except OSError:
        return None
    match = re.search(rf"^\s*export\s+{API_KEY_ENV}=['\"]?([^'\"\s]+)", content, re.MULTILINE)
    return match.group(1) if match else None


def api_get(path: str, key: str, deadline: float) -> dict[str, Any]:
    request = urllib.request.Request(
        API_BASE + path,
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "User-Agent": USER_AGENT,
        },
    )
    timeout = deadline - time.monotonic()
    if timeout <= 0:
        raise ProviderError("Timeout")
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            payload = json.loads(response.read().decode())
    except urllib.error.HTTPError as error:
        if error.code in (401, 403):
            raise ProviderError("Command Code key rejected") from error
        raise ProviderError(f"Command Code HTTP {error.code}") from error
    except (urllib.error.URLError, TimeoutError, OSError) as error:
        raise ProviderError(
            "Command Code unreachable", exception=type(error).__name__
        ) from error
    except json.JSONDecodeError as error:
        raise ProviderError("Invalid response", exception=type(error).__name__) from error
    if not isinstance(payload, dict):
        raise ProviderError("Invalid response")
    return payload


def parse_timestamp(value: Any) -> Optional[float]:
    if not isinstance(value, str) or not value:
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.timestamp()


def validate_window(window: Any) -> Optional[dict[str, float]]:
    if not isinstance(window, dict):
        return None
    used = float(window["used"])
    cap = float(window["cap"])
    if cap <= 0 or used < 0:
        raise ValueError
    if not all(math.isfinite(value) for value in (used, cap)):
        raise ValueError
    validated = {"used": used, "cap": cap}
    reset_at = window.get("resetAt")
    if isinstance(reset_at, (int, float)) and not isinstance(reset_at, bool):
        reset_seconds = float(reset_at) / 1000
        if reset_seconds <= 0 or not math.isfinite(reset_seconds):
            raise ValueError
        datetime.fromtimestamp(reset_seconds)
        validated["reset_at"] = reset_seconds
    return validated


def connect_database() -> sqlite3.Connection:
    """Open the Command Code history database and migrate older local schemas."""
    DB_PATH.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    connection = sqlite3.connect(DB_PATH, timeout=2.0)
    try:
        connection.execute(DB_SCHEMA)
        columns = {
            row[1] for row in connection.execute("PRAGMA table_info(usage_samples)")
        }
        for name, column_type in MIGRATION_COLUMNS.items():
            if name not in columns:
                connection.execute(
                    f"ALTER TABLE usage_samples ADD COLUMN {name} {column_type}"
                )
        connection.execute(DB_INDEX)
        connection.commit()
        return connection
    except sqlite3.Error:
        connection.close()
        raise


def read_cached_plan(now: float) -> dict[str, Any]:
    """Reuse a recent plan and period end from the usage history."""
    try:
        connection = connect_database()
        try:
            row = connection.execute(
                "SELECT plan, period_end, sampled_at FROM usage_samples "
                "WHERE period_end IS NOT NULL ORDER BY id DESC LIMIT 1"
            ).fetchone()
        finally:
            connection.close()
    except (OSError, sqlite3.Error):
        return {}
    if row is None:
        return {}
    plan, period_end, updated_at = row
    period_end = float(period_end)
    updated_at = float(updated_at)
    if not all(math.isfinite(value) for value in (updated_at, period_end)):
        return {}
    if period_end <= now or now - updated_at > PLAN_CACHE_TTL:
        return {}
    return {"plan": plan, "period_end": period_end}


def record_sample(usage: dict[str, Any], sampled_at: float) -> Optional[str]:
    """Append one history row unless every measured value matches the last row.

    Returns a short status for diagnostics; never raises, because a broken
    history database must not stop the tab bar from rendering.
    """
    five_hour = usage.get("five_hour") or {}
    week = usage.get("week") or {}
    sample = {
        "plan": usage.get("plan"),
        "five_hour_used": five_hour.get("used"),
        "five_hour_cap": five_hour.get("cap"),
        "five_hour_reset_at": five_hour.get("reset_at"),
        "weekly_used": week.get("used"),
        "weekly_cap": week.get("cap"),
        "weekly_reset_at": week.get("reset_at"),
        "month_used": usage.get("month_used"),
        "quota": usage.get("quota"),
        "period_end": usage.get("period_end"),
        "requests": usage.get("requests"),
        "average_cost": usage.get("average"),
    }
    row = (sampled_at, *(sample[field] for field in SAMPLE_FIELDS))
    try:
        connection = connect_database()
        try:
            last = connection.execute(
                "SELECT " + ", ".join(SAMPLE_FIELDS)
                + " FROM usage_samples ORDER BY id DESC LIMIT 1"
            ).fetchone()
            if last is not None and tuple(last) == row[1:]:
                return "unchanged"
            placeholders = ", ".join("?" for _ in row)
            connection.execute(
                "INSERT INTO usage_samples (sampled_at, "
                + ", ".join(SAMPLE_FIELDS)
                + f") VALUES ({placeholders})",
                row,
            )
            connection.commit()
            return "inserted"
        finally:
            connection.close()
    except (OSError, sqlite3.Error) as error:
        return f"error: {type(error).__name__}"


def read_usage() -> dict[str, Any]:
    deadline = time.monotonic() + TOTAL_TIMEOUT
    key = read_api_key()
    if not key:
        raise ProviderError(f"{API_KEY_ENV} not set")
    try:
        credits = api_get(CREDITS_ENDPOINT, key, deadline)
        credit_data = credits.get("credits")
        if not isinstance(credit_data, dict):
            raise ProviderError("Invalid response")
        try:
            summary = api_get(SUMMARY_ENDPOINT, key, deadline)
        except ProviderError:
            summary = {}

        usage: dict[str, Any] = {"plan": None}
        usage.update(read_cached_plan(time.time()))
        if "period_end" not in usage:
            try:
                subscriptions = api_get(SUBSCRIPTIONS_ENDPOINT, key, deadline)
            except ProviderError:
                subscriptions = {}
            plan_data = subscriptions.get("data")
            if isinstance(plan_data, dict):
                usage["plan"] = PLAN_LABELS.get(str(plan_data.get("planId", "")).lower())
                period_end = parse_timestamp(plan_data.get("currentPeriodEnd"))
                if period_end is not None:
                    usage["period_end"] = period_end
        windows = credits.get("windowLimits")
        if isinstance(windows, dict):
            for name, source in (("five_hour", "fiveHour"), ("week", "weekly")):
                window = validate_window(windows.get(source))
                if window is not None:
                    usage[name] = window
        if not any(usage.get(name) for name in ("five_hour", "week")):
            raise ProviderError("Invalid response")

        month_used = summary.get("totalCost")
        if isinstance(month_used, (int, float)) and not isinstance(month_used, bool):
            month_used = float(month_used)
            if math.isfinite(month_used) and month_used >= 0:
                usage["month_used"] = month_used
                balance = sum(
                    float(credit_data.get(field) or 0)
                    for field in ("monthlyCredits", "purchasedCredits", "freeCredits")
                )
                usage["quota"] = month_used + balance
        requests = summary.get("totalCount")
        if isinstance(requests, (int, float)) and not isinstance(requests, bool):
            usage["requests"] = float(requests)
        average = summary.get("averageCost")
        if isinstance(average, (int, float)) and not isinstance(average, bool):
            average = float(average)
            if math.isfinite(average) and average >= 0:
                usage["average"] = average
        return usage
    except ProviderError:
        raise
    except (KeyError, TypeError, ValueError, OverflowError) as error:
        raise ProviderError("Invalid response", exception=type(error).__name__) from error


def cached_usage() -> tuple[dict[str, Any], float]:
    connection = connect_database()
    try:
        row = connection.execute(
            "SELECT sampled_at, " + ", ".join(SAMPLE_FIELDS)
            + " FROM usage_samples ORDER BY id DESC LIMIT 1"
        ).fetchone()
    finally:
        connection.close()
    if row is None:
        raise ValueError
    (
        updated_at,
        plan,
        five_used,
        five_cap,
        five_reset,
        week_used,
        week_cap,
        week_reset,
        month_used,
        quota,
        period_end,
        requests,
        average,
    ) = row
    updated_at = float(updated_at)
    if updated_at <= 0 or not math.isfinite(updated_at):
        raise ValueError
    datetime.fromtimestamp(updated_at)
    usage: dict[str, Any] = {"plan": plan}
    for name, used, cap, reset_at in (
        ("five_hour", five_used, five_cap, five_reset),
        ("week", week_used, week_cap, week_reset),
    ):
        if used is None or cap is None:
            continue
        used = float(used)
        cap = float(cap)
        if used < 0 or cap <= 0 or not all(math.isfinite(value) for value in (used, cap)):
            raise ValueError
        window = {"used": used, "cap": cap}
        if reset_at is not None:
            reset_at = float(reset_at)
            if reset_at <= 0 or not math.isfinite(reset_at):
                raise ValueError
            datetime.fromtimestamp(reset_at)
            window["reset_at"] = reset_at
        usage[name] = window
    if not any(usage.get(name) for name in ("five_hour", "week")):
        raise ValueError
    for field, value in (
        ("month_used", month_used),
        ("quota", quota),
        ("requests", requests),
        ("average", average),
        ("period_end", period_end),
    ):
        if value is None:
            continue
        value = float(value)
        if not math.isfinite(value) or value < 0:
            raise ValueError
        usage[field] = value
    return usage, updated_at


def record_error(error: ProviderError) -> None:
    payload: dict[str, Any] = {
        "timestamp": datetime.now().astimezone().isoformat(),
        "category": error.reason,
    }
    if error.exception is not None:
        payload["exception"] = error.exception
    atomic_write(DIAGNOSTIC_PATH, json.dumps(payload))


def clear_error() -> None:
    try:
        DIAGNOSTIC_PATH.unlink()
    except OSError:
        pass


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
        print(f"Command Code --・{error.reason}")


def print_history(limit: int) -> None:
    """Print the most recent stored samples, newest first."""
    if not DB_PATH.exists():
        print(f"No history database at {DB_PATH} yet.")
        return
    try:
        connection = connect_database()
        try:
            rows = connection.execute(
                "SELECT sampled_at, five_hour_used, weekly_used, month_used, "
                "requests, average_cost FROM usage_samples ORDER BY sampled_at DESC LIMIT ?",
                (limit,),
            ).fetchall()
        finally:
            connection.close()
    except (OSError, sqlite3.Error) as error:
        print(f"Cannot read history: {type(error).__name__}")
        return
    if not rows:
        print("No samples recorded yet.")
        return
    print(f"{'when':<17}{'5h':>9}{'7d':>9}{'month':>9}{'req':>8}{'avg':>10}{'d(5h)':>9}")
    total = len(rows)
    for index, row in enumerate(rows):
        sampled_at, five_hour, weekly, month, requests, average = row
        when = datetime.fromtimestamp(sampled_at).astimezone().strftime("%m-%d %H:%M:%S")
        delta = ""
        previous_five_hour = rows[index + 1][1] if index + 1 < total else None
        if five_hour is not None and previous_five_hour is not None:
            delta = f"  +{five_hour - previous_five_hour:.3f}"
        five_hour_text = "-" if five_hour is None else f"{five_hour:.3f}"
        weekly_text = "-" if weekly is None else f"{weekly:.3f}"
        month_text = "-" if month is None else f"{month:.3f}"
        requests_text = "-" if requests is None else str(int(requests))
        average_text = "-" if average is None else f"{average:.4f}"
        print(
            f"{when:<17}{five_hour_text:>9}{weekly_text:>9}{month_text:>9}"
            f"{requests_text:>8}{average_text:>10}{delta}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--history", type=int, metavar="N", help="print the last N stored samples")
    arguments = parser.parse_args()
    if arguments.history is not None:
        print_history(max(1, arguments.history))
        return
    try:
        usage = read_usage()
    except ProviderError as error:
        render_failure(error)
        return
    record_sample(usage, time.time())
    try:
        clear_error()
    except OSError:
        pass
    print(display(usage))


if __name__ == "__main__":
    main()
