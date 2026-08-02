#!/usr/bin/env bash

set -euo pipefail

readonly target_window_id="${1:?Kitty smart paste: missing target window ID}"
readonly smart_paste_tmp_root="${TMPDIR:-/tmp}"

clipboard_contains_text() {
  /usr/bin/osascript <<'APPLESCRIPT' >/dev/null 2>&1
set clipboardInfo to clipboard info

repeat with flavorInfo in clipboardInfo
  set flavorType to item 1 of flavorInfo
  if flavorType is «class utf8» or flavorType is «class ut16» or flavorType is string or flavorType is Unicode text then
    return
  end if
end repeat

error number 1
APPLESCRIPT
}

paste_clipboard_text() {
  kitten @ action \
    --match "id:${target_window_id}" \
    paste_from_clipboard
}

send_image_path_to_kitty_window() {
  kitten @ send-text \
    --match "id:${target_window_id}" \
    --stdin \
    --bracketed-paste=auto
}

write_clipboard_data() {
  local clipboard_type="$1"
  local output_path="$2"

  /usr/bin/osascript - "$clipboard_type" "$output_path" <<'APPLESCRIPT' 2>/dev/null
on run argv
  set clipboardType to item 1 of argv
  set outputPath to item 2 of argv

  if clipboardType is "PNG" then
    set clipboardData to the clipboard as «class PNGf»
  else
    set clipboardData to the clipboard as TIFF picture
  end if

  set outputFile to open for access POSIX file outputPath with write permission
  try
    set eof of outputFile to 0
    write clipboardData to outputFile
    close access outputFile
  on error errorMessage number errorNumber
    try
      close access outputFile
    end try
    error errorMessage number errorNumber
  end try
end run
APPLESCRIPT
}

create_clipboard_png() {
  local image_directory
  local png_path
  local tiff_path

  image_directory="$(mktemp -d "${smart_paste_tmp_root%/}/kitty-smart-paste.XXXXXX")"
  png_path="${image_directory}/clipboard.png"
  tiff_path="${image_directory}/clipboard.tiff"

  if write_clipboard_data PNG "$png_path"; then
    printf '%s' "$png_path"
    return 0
  fi

  if write_clipboard_data TIFF "$tiff_path" && \
    /usr/bin/sips --setProperty format png "$tiff_path" --out "$png_path" >/dev/null 2>&1; then
    rm -f "$tiff_path"
    printf '%s' "$png_path"
    return 0
  fi

  rm -f "$png_path" "$tiff_path"
  rmdir "$image_directory"
  return 1
}

if clipboard_contains_text; then
  paste_clipboard_text
elif clipboard_png_path="$(create_clipboard_png)"; then
  printf '%q' "$clipboard_png_path" | send_image_path_to_kitty_window
fi
