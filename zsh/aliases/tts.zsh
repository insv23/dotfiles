# 文字转语音工具
# --------------------------------------------------

_tts_help() {
  cat <<'EOF'
用法:
  tts '要朗读的内容'
  tts -d '要保存成 mp3 的内容'

选项:
  -d, --download   保存音频到当前目录
  -h, --help       显示帮助

示例:
  tts 'Codex 输出已结束!'
  tts -d 'Codex 输出已结束!'
EOF
}

_tts_download_audio() {
  local text_to_speak="$1"
  local output_path="$2"
  local voice="zh-CN-XiaoshuangNeural"
  local rate="0"
  local pitch="0"
  local base_url="https://libretts.is-an.org/api/tts"

  curl -sS -L -G \
    -o "${output_path}" \
    --data-urlencode "t=${text_to_speak}" \
    --data-urlencode "v=${voice}" \
    --data-urlencode "r=${rate}" \
    --data-urlencode "p=${pitch}" \
    "${base_url}"
}

_tts_output_path() {
  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"
  echo "${PWD}/tts-${timestamp}.mp3"
}

tts() {
  local mode="play"
  local text_to_speak
  local output_path
  local temp_file

  if [ "$#" -eq 0 ]; then
    _tts_help
    return 0
  fi

  case "$1" in
    -h|--help)
      if [ "$#" -ne 1 ]; then
        echo "错误: 帮助选项不接受额外参数。"
        _tts_help
        return 1
      fi
      _tts_help
      return 0
      ;;
    -d|--download)
      mode="download"
      shift
      ;;
    -*)
      echo "错误: 未知选项: $1"
      _tts_help
      return 1
      ;;
  esac

  if [ "$#" -ne 1 ]; then
    echo "错误: 请提供一个文本字符串。"
    _tts_help
    return 1
  fi

  text_to_speak="$1"

  if [ -z "$text_to_speak" ]; then
    echo "错误: 文本不能为空。"
    _tts_help
    return 1
  fi

  if [ "$mode" = "download" ]; then
    output_path="$(_tts_output_path)"
    echo "正在转换文字: '${text_to_speak}'"
    echo "保存到: ${output_path}"

    if _tts_download_audio "$text_to_speak" "$output_path" && [ -s "$output_path" ]; then
      echo "成功: 文件已保存到 ${output_path}"
      return 0
    fi

    rm -f "$output_path"
    echo "错误: 转换失败。请检查网络连接或 API 是否可用。"
    return 1
  fi

  if ! command -v afplay >/dev/null 2>&1; then
    echo "错误: 未找到 afplay，当前播放模式仅适用于 macOS。"
    echo "可以使用: tts -d '要保存成 mp3 的内容'"
    return 1
  fi

  temp_file="$(mktemp /tmp/tts-audio.XXXXXX.mp3)"
  echo "正在转换并播放: '${text_to_speak}'"

  if _tts_download_audio "$text_to_speak" "$temp_file" && [ -s "$temp_file" ]; then
    afplay "$temp_file"
    rm -f "$temp_file"
    echo "播放完成。"
    return 0
  fi

  rm -f "$temp_file"
  echo "错误: 转换失败。请检查网络连接或 API 是否可用。"
  return 1
}
