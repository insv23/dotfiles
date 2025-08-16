# 函数：执行一个命令，并将其所有输出（stdout和stderr）
# 同时显示在屏幕上，并追加到以该命令命名的日志文件中。
l() {
  # 检查是否提供了命令
  if [ "$#" -eq 0 ]; then
    echo "错误: 请提供要执行的命令。"
    echo "用法: l <command> [args...]"
    return 1
  fi

  # 从命令和参数中创建一个安全的文件名
  # 将空格和斜杠替换为下划线，并压缩连续的下划线
  local log_filename
  log_filename=$(echo "$@" | tr -s ' /' '_' )_output.log

  # 打印提示信息，告知用户正在执行什么以及日志文件在哪里
  echo "---"
  echo "🚀 Executing: $@"
  echo "📄 Logging to: ${log_filename}"
  echo "---"

  # 执行命令。"$@" 会将所有参数原封不动地传递下去，
  # 即使参数中包含空格也能正确处理。
  # 2>&1 将标准错误重定向到标准输出
  # | tee -a 将合并后的输出流追加到日志文件并显示在屏幕上
  "$@" 2>&1 | tee -a "$log_filename"
}
