#!/usr/bin/env python3
"""Print Apple Silicon total power for Herdr's tab bar."""

import json
import math
import shutil
import subprocess
from typing import Any, Optional


COMMAND_TIMEOUT_SECONDS = 8.0


def positive_number(value: Any) -> Optional[float]:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return None
    number = float(value)
    return number if math.isfinite(number) and number > 0 else None


def read_power(record: dict[str, Any]) -> Optional[float]:
    power = positive_number(record.get("sys_power"))
    if power is not None:
        return power

    structured_power = record.get("power")
    if isinstance(structured_power, dict):
        for field in ("board", "system"):
            power = positive_number(structured_power.get(field))
            if power is not None:
                return power
    return None


def main() -> None:
    output = "Power --"
    macmon = shutil.which("macmon")
    if macmon is not None:
        try:
            result = subprocess.run(
                [macmon, "-i", "1000", "pipe", "-s", "1"],
                capture_output=True,
                text=True,
                timeout=COMMAND_TIMEOUT_SECONDS,
                check=True,
            )
            line = next(
                line for line in result.stdout.splitlines() if line.strip()
            )
            record = json.loads(line)
            if isinstance(record, dict):
                power = read_power(record)
                if power is not None:
                    output = f"Power {power:.1f}W"
        except (
            OSError,
            StopIteration,
            subprocess.CalledProcessError,
            subprocess.TimeoutExpired,
            json.JSONDecodeError,
            ValueError,
        ):
            pass
    print(output)


if __name__ == "__main__":
    main()
