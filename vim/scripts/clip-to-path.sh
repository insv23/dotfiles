#!/usr/bin/env bash
# 打印剪贴板里的图片路径，没有图片时退回剪贴板文本。给 vim 的 Cmd+V 映射调用。
#
# 为什么需要它：vim 只能读文本剪贴板（pbpaste），拿不到 macOS 剪贴板里的图片数据，
# 图片必须先落盘成文件，vim 才有东西可插入。
#
# 为什么放在 vim/scripts 下：vimrc 用仓库绝对路径直接调用它（和 packpath 一样的做法），
# 不进 dotdrop 的映射表，也就不需要符号链接和 install/update 同步。

set -euo pipefail

readonly output_root="${TMPDIR:-/tmp}/clip-to-path"
readonly keep_days=7

# 从剪贴板取出指定类型写入文件。剪贴板里没有该类型时 osascript 会报错并返回非零。
write_clipboard_data() {
  local clipboard_type="$1"
  local output_path="$2"

  /usr/bin/osascript - "$clipboard_type" "$output_path" <<'APPLESCRIPT' >/dev/null 2>&1
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

main() {
  local stamp png_path tiff_path

  mkdir -p "$output_root"
  # 落盘的图片只在插入路径那一刻有用，过期就删，免得缓存目录越积越多
  find "$output_root" -type f -mtime "+${keep_days}" -delete 2>/dev/null || true

  stamp="$(date +%Y%m%d-%H%M%S)-$$"
  png_path="${output_root}/clipboard-${stamp}.png"
  tiff_path="${output_root}/clipboard-${stamp}.tiff"

  if write_clipboard_data PNG "$png_path"; then
    printf '%s' "$png_path"
    return 0
  fi

  # 部分截图路径只给 TIFF，转成 PNG 再交给下游（agent 只认常见的图片扩展名）
  if write_clipboard_data TIFF "$tiff_path" && \
    /usr/bin/sips --setProperty format png "$tiff_path" --out "$png_path" >/dev/null 2>&1; then
    rm -f "$tiff_path"
    printf '%s' "$png_path"
    return 0
  fi

  rm -f "$png_path" "$tiff_path"
  /usr/bin/pbpaste
}

main "$@"
