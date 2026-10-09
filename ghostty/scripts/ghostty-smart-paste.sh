#!/usr/bin/env bash
# Ghostty 版智能粘贴，由 Karabiner 在 Ghostty 前台时拦截 Cmd+V 后调用。
# 文本直接粘贴；只有图片时存成临时 PNG 并粘贴其路径。
# Ghostty 没有按键启动外部命令的能力，所以触发靠 Karabiner，注入靠 AppleScript。

set -euo pipefail

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

# perform action 走 Ghostty 自己的粘贴逻辑（含 bracketed paste 与粘贴保护），与原生 Cmd+V 一致
paste_clipboard_text() {
  /usr/bin/osascript <<'APPLESCRIPT'
tell application "Ghostty"
  set term to focused terminal of selected tab of front window
  perform action "paste_from_clipboard" on term
end tell
APPLESCRIPT
}

# 路径经 argv 传入，免去 AppleScript 字符串转义；input text 按粘贴方式写入
send_text_to_ghostty() {
  /usr/bin/osascript - "$1" <<'APPLESCRIPT'
on run argv
  tell application "Ghostty"
    set term to focused terminal of selected tab of front window
    input text (item 1 of argv) to term
  end tell
end run
APPLESCRIPT
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

  image_directory="$(mktemp -d "${smart_paste_tmp_root%/}/ghostty-smart-paste.XXXXXX")"
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
  send_text_to_ghostty "$(printf '%q' "$clipboard_png_path")"
fi
