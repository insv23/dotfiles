#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Excalidraw Live Room
# @raycast.mode silent
# @raycast.icon ✏️
# @raycast.description Create and open a new Excalidraw live collaboration room
# @raycast.packageName Excalidraw

url="$(/usr/bin/python3 - <<'PY'
import base64
import secrets

room_id = secrets.token_hex(10)
room_key = base64.urlsafe_b64encode(secrets.token_bytes(16)).decode().rstrip("=")

print(f"https://excalidraw.com/#room={room_id},{room_key}")
PY
)"

open "$url"
