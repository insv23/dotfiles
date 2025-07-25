# Bark 通知配置
# 优先使用环境变量，如果没有则使用默认值（建议通过 bark_init 设置）
BARK_KEY="${BARK_KEY:-}"
BARK_THRESHOLD="${BARK_THRESHOLD:-10}"  # 可通过环境变量覆盖
BARK_ENABLED="${BARK_ENABLED:-true}"    # 可通过环境变量控制

# 忽略的命令列表
BARK_IGNORE_CMDS=(ssh kitten k autossh vi vim nvim nv zja y)

# 记录命令信息
typeset -g BARK_CMD_START
typeset -g BARK_CMD_STRING

# 发送 Bark 通知
bark_send() {
  # 检查 key 是否存在
  # 如果没有配置 BARK_KEY，通知功能会自动禁用，不会影响正常的命令执行，也不会产生任何输出或错误信息。
  if [[ -z "$BARK_KEY" ]]; then
    return 1
  fi
  
  local title="$1"
  local body="$2"
  local sound="${3:-glass}" # Sound 参数是 iOS 专用的，默认是 "default"
  local group="${4:-$(hostname -s)}"
  
  # 转义特殊字符
  body="${body//\"/\\\"}"
  body="${body//$'\n'/\\n}"
  
  (curl -X POST "https://api.day.app/push" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "{\"body\": \"$body\", \"title\": \"$title\", \"device_key\": \"$BARK_KEY\", \"sound\": \"$sound\", \"group\": \"$group\"}" \
    --silent >/dev/null 2>&1 &)
}

# preexec hook - 命令开始前
bark_preexec() {
  [[ -z "$1" ]] && return
  
  BARK_CMD_START=$SECONDS
  # 截断长命令
  BARK_CMD_STRING="${1:0:50}"
  [[ ${#1} -gt 50 ]] && BARK_CMD_STRING="${BARK_CMD_STRING}..."
}

# precmd hook - 命令结束后
bark_precmd() {
  local exit_code=$?
  
  # 检查是否启用
  [[ "$BARK_ENABLED" != "true" ]] && return
  
  # 检查是否有开始时间
  [[ -z "$BARK_CMD_START" ]] && return
  
  local duration=$((SECONDS - BARK_CMD_START))
  unset BARK_CMD_START
  
  # 检查时间阈值
  [[ $duration -lt $BARK_THRESHOLD ]] && return
  
  # 检查命令黑名单
  local first_cmd="${BARK_CMD_STRING%% *}"
  for ignore in "${BARK_IGNORE_CMDS[@]}"; do
    [[ "$first_cmd" == "$ignore" ]] && return
  done
  
  # 格式化时间
  local duration_time_str
  if [[ $duration -ge 86400 ]]; then
    # 超过1天：显示 x天y小时z分w秒
    local days=$((duration / 86400))
    local hours=$(((duration % 86400) / 3600))
    local mins=$(((duration % 3600) / 60))
    local secs=$((duration % 60))
    duration_time_str="${days}天"
    [[ $hours -gt 0 ]] && duration_time_str="${duration_time_str}${hours}小时"
    [[ $mins -gt 0 ]] && duration_time_str="${duration_time_str}${mins}分"
    [[ $secs -gt 0 ]] && duration_time_str="${duration_time_str}${secs}秒"
  elif [[ $duration -ge 3600 ]]; then
    # 1小时-1天：显示 x小时y分z秒
    local hours=$((duration / 3600))
    local mins=$(((duration % 3600) / 60))
    local secs=$((duration % 60))
    duration_time_str="${hours}小时"
    [[ $mins -gt 0 ]] && duration_time_str="${duration_time_str}${mins}分"
    [[ $secs -gt 0 ]] && duration_time_str="${duration_time_str}${secs}秒"
  elif [[ $duration -ge 60 ]]; then
    # 1分钟-1小时：显示 x分y秒
    local mins=$((duration / 60))
    local secs=$((duration % 60))
    duration_time_str="${mins}分"
    [[ $secs -gt 0 ]] && duration_time_str="${duration_time_str}${secs}秒"
  else
    # 少于1分钟：显示 x秒
    duration_time_str="${duration}秒"
  fi
  
  # 构建通知
  local title sound group host
  host="[$(hostname -s)]"
  
  if [[ $exit_code -eq 0 ]]; then
    title="${host}✅ 命令完成"
    sound="glass"
    group="$(hostname -s)"
  else
    title="${host}❌ 命令失败"
    sound="alarm"
    group="$(hostname -s)-failed"
  fi
  
  local body="命令: ${BARK_CMD_STRING}\n持续时间: ${duration_time_str}\n发送时间: $(date '+%H:%M:%S')"
  
  bark_send "$title" "$body" "$sound" "$group"
}

# 注册 hooks
autoload -Uz add-zsh-hook
add-zsh-hook preexec bark_preexec
add-zsh-hook precmd bark_precmd

# ===== 控制函数 =====

# 启用/禁用通知
bark_enable() {
  export BARK_ENABLED="true"
  echo "✅ Bark 通知已启用"
}

bark_disable() {
  export BARK_ENABLED="false"
  echo "❌ Bark 通知已禁用"
}

# 设置时间阈值
bark_set_threshold() {
  if [[ -z "$1" ]]; then
    echo "当前阈值: ${BARK_THRESHOLD}秒"
    echo "使用方法: bark_set_threshold <秒数>"
  else
    export BARK_THRESHOLD="$1"
    echo "⏱️  Bark 通知阈值已设置为: ${BARK_THRESHOLD}秒"
  fi
}

# 查看当前状态
bark_status() {
  echo "Bark 通知状态:"
  echo "  启用状态: $BARK_ENABLED"
  echo "  时间阈值: ${BARK_THRESHOLD}秒"
  echo "  忽略命令: ${BARK_IGNORE_CMDS[*]}"
  echo "  当前主机: $(hostname -s)"
}

# 手动通知命令包装器
bn() {
  local start=$SECONDS
  "$@"
  local exit_code=$?
  local duration=$((SECONDS - start))
  
  local status_msg
  if [[ $exit_code -eq 0 ]]; then
    status_msg="✅ 成功"
  else
    status_msg="❌ 失败 (退出码: $exit_code)"
  fi
  
  bark_send "命令完成" "$1\n执行时间: ${duration}秒\n$status_msg"
  return $exit_code
}

# 测试通知
bark_test() {
  if [[ -z "$BARK_KEY" ]]; then
    echo "❌ 错误：BARK_KEY 未设置"
    echo "请先运行 bark_init 进行初始化"
    return 1
  fi
  
  echo "📱 发送测试通知..."
  local host="[$(hostname -s)]"
  bark_send "${host}🧪 Bark 测试" "命令: bark_test\n持续时间: 0秒\n发送时间: $(date '+%H:%M:%S')" "bell" "$(hostname -s)-test"
  echo "如果配置正确，你应该会收到通知"
}

# 初始化 Bark key
bark_init() {
  echo "🔧 Bark 通知初始化"
  echo ""
  
  # 检查是否已有 key
  if [[ -n "$BARK_KEY" ]]; then
    echo "当前已配置 BARK_KEY"
    echo -n "是否要重新设置？[y/N] "
    read -r response
    [[ "$response" != "y" ]] && return 0
  fi
  
  # 输入新 key
  echo -n "请输入你的 Bark Key: "
  read -r new_key
  
  if [[ -z "$new_key" ]]; then
    echo "❌ Key 不能为空"
    return 1
  fi
  
  # 保存到 ~/.envrc
  local envrc_file="$HOME/.envrc"
  
  # 检查文件是否存在，如果不存在则创建
  if [[ ! -f "$envrc_file" ]]; then
    touch "$envrc_file"
    chmod 600 "$envrc_file"
  fi
  
  # 检查是否已有 BARK_KEY
  if grep -q "^export BARK_KEY=" "$envrc_file"; then
    # 更新现有的 key
    sed -i '' "s/^export BARK_KEY=.*/export BARK_KEY=\"$new_key\"/" "$envrc_file"
  else
    # 添加新 key
    echo "export BARK_KEY=\"$new_key\"" >> "$envrc_file"
  fi
  
  # 立即生效
  export BARK_KEY="$new_key"
  
  echo "✅ BARK_KEY 已保存到 ~/.envrc"
  echo ""

  # 自动运行 direnv allow
  if command -v direnv &>/dev/null; then
    # 保存当前目录
    local current_dir=$(pwd)
    # 切换到 home 目录执行 direnv allow
    cd ~
    direnv allow
    # 返回原目录
    cd "$current_dir"
    echo "✅ 已在 ~ 目录下执行 direnv allow"
  fi
  
  echo ""
  echo "📝 远程主机使用说明："
  echo "1. 在远程主机上也运行相同的配置："
  echo "   • 将 bark_notify.zsh 复制到远程主机"
  echo "   • 在远程主机运行 bark_init 设置相同的 key"
  echo "   • 或者直接在远程主机的 ~/.envrc 中添加："
  echo "     export BARK_KEY=\"你的key\""
  echo "   • 在远程主机运行 direnv allow"
  echo ""
  echo "2. 这样本地和远程都能独立使用 Bark 通知"
  echo ""
  echo "现在可以运行 bark_test 测试通知功能"
}