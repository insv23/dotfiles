# --------------------------------------------------
# 文字转语音工具 (macOS 和 Linux)
# --------------------------------------------------

# (ttsd) - 将文字转换为语音并【下载】到 Downloads 文件夹
# 用法: ttsd "你要转换的文字"
ttsd() {
  # 检查用户是否提供了文字参数
  if [ -z "$1" ]; then
    echo "错误: 请提供要转换的文字。"
    echo "用法: ttsd \"你要转换的文字\""
    return 1
  fi

  local text_to_speak="$1"
  local output_dir="$HOME/Downloads"
  local output_filename="${text_to_speak}.mp3"
  local output_path="${output_dir}/${output_filename}"
  local voice="zh-CN-XiaoshuangNeural"
  local rate="0"
  local pitch="0"
  local base_url="https://libretts.is-an.org/api/tts"

  echo "正在转换文字: \"${text_to_speak}\""
  echo "准备下载到: ${output_path}"
  
  # 使用 curl 下载文件
  curl -L -G \
    -o "${output_path}" \
    --data-urlencode "t=${text_to_speak}" \
    --data-urlencode "v=${voice}" \
    --data-urlencode "r=${rate}" \
    --data-urlencode "p=${pitch}" \
    "${base_url}"

  if [ $? -eq 0 ]; then
    echo "✅ 成功！文件已保存到: ${output_path}"
  else
    echo "❌ 下载失败。请检查网络连接或 API 是否可用。"
    return 1
  fi
}


# (tts) - 将文字转换为语音并【直接播放】(需要 afplay, 仅限 macOS)
# 用法: tts "你要转换的文字"
tts() {
  # 检查 afplay 命令是否存在
  if ! command -v afplay &> /dev/null; then
    echo "错误: 'afplay' 命令未找到。此功能仅适用于 macOS。"
    echo "如需下载文件，请改用 'ttsd' 命令。"
    return 1
  fi
  
  # 检查用户是否提供了文字参数
  if [ -z "$1" ]; then
    echo "错误: 请提供要转换的文字。"
    echo "用法: tts \"你要转换的文字\""
    return 1
  fi

  local text_to_speak="$1"
  local voice="zh-CN-XiaoshuangNeural"
  local rate="0"
  local pitch="0"
  local base_url="https://libretts.is-an.org/api/tts"
  
  # 创建一个临时文件来存放音频
  # mktemp 会创建一个唯一的临时文件，并返回其路径
  # trap 命令确保脚本退出时（无论成功失败），临时文件都会被删除
  local temp_file=$(mktemp /tmp/tts_audio.XXXXXX.mp3)
  trap 'rm -f "$temp_file"' EXIT

  echo "正在转换文字并准备播放: \"${text_to_speak}\""

  # 使用 curl 下载音频到临时文件
  # -s: 静默模式，不显示进度条
  # -S: 在静默模式下，如果发生错误，仍然显示错误信息
  curl -sS -L -G \
    -o "${temp_file}" \
    --data-urlencode "t=${text_to_speak}" \
    --data-urlencode "v=${voice}" \
    --data-urlencode "r=${rate}" \
    --data-urlencode "p=${pitch}" \
    "${base_url}"

  # 检查下载是否成功
  if [ $? -eq 0 ] && [ -s "$temp_file" ]; then
    # 使用 afplay 播放临时文件中的音频
    afplay "$temp_file"
    echo "✅ 播放完成。"
  else
    echo "❌ 转换失败。请检查网络连接或 API 是否可用。"
    return 1
  fi
}
