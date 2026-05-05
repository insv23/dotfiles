# iOS 推送通知：通过 Bark App 在长命令结束后发送通知

BARK_KEY="${BARK_KEY:-}"
BARK_THRESHOLD="${BARK_THRESHOLD:-10}"
BARK_ENABLED="${BARK_ENABLED:-true}"
BARK_IGNORE_FILE="${BARK_IGNORE_FILE:-$HOME/.dotfiles/zsh/aliases/bark.ignore}"

typeset -g BARK_CMD_START
typeset -g BARK_CMD_RAW
typeset -g BARK_CMD_SHORT
typeset -ga BARK_IGNORE_PREFIXES

_bark_escape_json() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  print -r -- "$value"
}

_bark_send() {
  [[ -n "$BARK_KEY" ]] || return 1

  local title="$1"
  local body="$2"
  local sound="${3:-glass}"
  local group="${4:-$(hostname -s)}"

  title="$(_bark_escape_json "$title")"
  body="$(_bark_escape_json "$body")"

  (command curl -X POST "https://api.day.app/push" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "{\"body\": \"$body\", \"title\": \"$title\", \"device_key\": \"$BARK_KEY\", \"sound\": \"$sound\", \"group\": \"$group\"}" \
    --silent >/dev/null 2>&1 &)
}

_bark_format_duration() {
  local duration="$1"

  if [[ "$duration" -ge 86400 ]]; then
    local days=$((duration / 86400))
    local hours=$(((duration % 86400) / 3600))
    local mins=$(((duration % 3600) / 60))
    local secs=$((duration % 60))
    local result="${days}天"
    [[ "$hours" -gt 0 ]] && result="${result}${hours}小时"
    [[ "$mins" -gt 0 ]] && result="${result}${mins}分"
    [[ "$secs" -gt 0 ]] && result="${result}${secs}秒"
    print -r -- "$result"
    return 0
  fi

  if [[ "$duration" -ge 3600 ]]; then
    local hours=$((duration / 3600))
    local mins=$(((duration % 3600) / 60))
    local secs=$((duration % 60))
    local result="${hours}小时"
    [[ "$mins" -gt 0 ]] && result="${result}${mins}分"
    [[ "$secs" -gt 0 ]] && result="${result}${secs}秒"
    print -r -- "$result"
    return 0
  fi

  if [[ "$duration" -ge 60 ]]; then
    local mins=$((duration / 60))
    local secs=$((duration % 60))
    local result="${mins}分"
    [[ "$secs" -gt 0 ]] && result="${result}${secs}秒"
    print -r -- "$result"
    return 0
  fi

  print -r -- "${duration}秒"
}

_bark_ensure_ignore_file() {
  [[ -f "$BARK_IGNORE_FILE" ]] && return 0
  mkdir -p "${BARK_IGNORE_FILE:h}"
  touch "$BARK_IGNORE_FILE"
}

_bark_load_ignore_list() {
  BARK_IGNORE_PREFIXES=()
  [[ -f "$BARK_IGNORE_FILE" ]] || return 0

  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" == \#* ]] && continue
    BARK_IGNORE_PREFIXES+=("$line")
  done < "$BARK_IGNORE_FILE"
}

_bark_has_prefix() {
  local cmd="$1"
  local prefix="$2"
  local prefix_len=${#prefix}

  [[ "$prefix_len" -gt 0 ]] || return 1
  [[ "${cmd[1,prefix_len]}" == "$prefix" ]] || return 1

  local next_char="${cmd[$((prefix_len + 1))]}"
  [[ -z "$next_char" || "$next_char" == " " ]]
}

_bark_is_ignored() {
  local cmd="$1"
  local prefix

  _bark_load_ignore_list
  for prefix in "${BARK_IGNORE_PREFIXES[@]}"; do
    _bark_has_prefix "$cmd" "$prefix" && return 0
  done
  return 1
}

_bark_print_setup_hint() {
  print "BARK_KEY 未设置"
  print ""
  print "推荐做法："
  print "  1. 在你的 shell secret 文件中加入："
  print '     export BARK_KEY="你的key"'
  print "  2. 重新加载 shell："
  print "     exec zsh"
  print "  3. 运行测试："
  print "     bark test"
}

_bark_require_key() {
  [[ -n "$BARK_KEY" ]] && return 0
  _bark_print_setup_hint
  return 1
}

_bark_print_status() {
  _bark_load_ignore_list

  local key_status="未配置"
  [[ -n "$BARK_KEY" ]] && key_status="已配置"

  print "Bark 状态:"
  print "  启用状态: $BARK_ENABLED"
  print "  时间阈值: ${BARK_THRESHOLD}秒"
  print "  BARK_KEY: $key_status"
  print "  当前主机: $(hostname -s)"
  print "  忽略文件: $BARK_IGNORE_FILE"
  print "  忽略规则: ${#BARK_IGNORE_PREFIXES[@]} 条"
}

_bark_print_help() {
  print "用法:"
  print "  bark                         显示状态和帮助"
  print "  bark help                    显示帮助"
  print "  bark status                  显示当前状态"
  print "  bark test                    发送测试通知"
  print "  bark enable                  启用自动通知"
  print "  bark disable                 禁用自动通知"
  print "  bark threshold               显示当前阈值"
  print "  bark threshold <秒数>        设置当前会话的通知阈值"
  print "  bark ignore list             显示忽略列表"
  print "  bark ignore add <前缀>       添加命令前缀到忽略列表"
  print "  bark ignore remove <前缀>    从忽略列表移除命令前缀"
}

_bark_print_ignore_list() {
  _bark_load_ignore_list

  print "忽略列表:"
  if [[ "${#BARK_IGNORE_PREFIXES[@]}" -eq 0 ]]; then
    print "  (空)"
    return 0
  fi

  local i=1
  local prefix
  for prefix in "${BARK_IGNORE_PREFIXES[@]}"; do
    printf "  %d. %s\n" "$i" "$prefix"
    ((i++))
  done
}

_bark_ignore_add() {
  local prefix="$*"
  [[ -n "$prefix" ]] || {
    print "用法: bark ignore add <前缀>" >&2
    return 1
  }

  _bark_ensure_ignore_file
  _bark_load_ignore_list

  local existing
  for existing in "${BARK_IGNORE_PREFIXES[@]}"; do
    if [[ "$existing" == "$prefix" ]]; then
      print "忽略前缀已存在: $prefix"
      return 0
    fi
  done

  printf "%s\n" "$prefix" >> "$BARK_IGNORE_FILE"
  print "已添加忽略前缀: $prefix"
}

_bark_ignore_remove() {
  local prefix="$*"
  [[ -n "$prefix" ]] || {
    print "用法: bark ignore remove <前缀>" >&2
    return 1
  }

  _bark_ensure_ignore_file

  local tmp_file
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/bark.ignore.XXXXXX")" || return 1

  local removed="false"
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$prefix" ]]; then
      removed="true"
      continue
    fi
    printf "%s\n" "$line" >> "$tmp_file"
  done < "$BARK_IGNORE_FILE"

  if [[ "$removed" != "true" ]]; then
    rm -f "$tmp_file"
    print "未找到忽略前缀: $prefix" >&2
    return 1
  fi

  mv "$tmp_file" "$BARK_IGNORE_FILE"
  print "已移除忽略前缀: $prefix"
}

_bark_preexec() {
  [[ -n "$1" ]] || return

  BARK_CMD_START=$SECONDS
  BARK_CMD_RAW="$1"
  BARK_CMD_SHORT="$1"

  [[ ${#BARK_CMD_SHORT} -gt 80 ]] && BARK_CMD_SHORT="${BARK_CMD_SHORT:0:80}..."
}

_bark_precmd() {
  local exit_code=$?

  [[ "$BARK_ENABLED" == "true" ]] || return
  [[ -n "$BARK_CMD_START" ]] || return
  [[ "$BARK_THRESHOLD" == <-> ]] || return

  local duration=$((SECONDS - BARK_CMD_START))
  local cmd_raw="$BARK_CMD_RAW"
  local cmd_short="$BARK_CMD_SHORT"

  unset BARK_CMD_START
  unset BARK_CMD_RAW
  unset BARK_CMD_SHORT

  [[ "$duration" -lt "$BARK_THRESHOLD" ]] && return
  _bark_is_ignored "$cmd_raw" && return

  local host="[$(hostname -s)]"
  local title sound group
  if [[ "$exit_code" -eq 0 ]]; then
    title="${host}✅ 命令完成"
    sound="glass"
    group="$(hostname -s)"
  else
    title="${host}❌ 命令失败"
    sound="alarm"
    group="$(hostname -s)-failed"
  fi

  local duration_text
  duration_text="$(_bark_format_duration "$duration")"
  local body="命令: ${cmd_short}
持续时间: ${duration_text}
发送时间: $(date '+%H:%M:%S')"

  _bark_send "$title" "$body" "$sound" "$group"
}

bark() {
  local cmd="${1:-}"

  case "$cmd" in
    ""|help|-h|--help)
      _bark_print_status
      print ""
      [[ -n "$BARK_KEY" ]] || {
        _bark_print_setup_hint
        print ""
      }
      _bark_print_help
      ;;
    status)
      _bark_print_status
      [[ -n "$BARK_KEY" ]] || {
        print ""
        _bark_print_setup_hint
      }
      ;;
    test)
      _bark_require_key || return 1
      print "发送测试通知..."
      _bark_send "[$(hostname -s)]🧪 Bark 测试" "命令: bark test
持续时间: 0秒
发送时间: $(date '+%H:%M:%S')" "bell" "$(hostname -s)-test"
      print "如果配置正确，你应该会收到通知"
      ;;
    enable)
      export BARK_ENABLED="true"
      print "Bark 通知已启用"
      ;;
    disable)
      export BARK_ENABLED="false"
      print "Bark 通知已禁用"
      ;;
    threshold)
      if [[ -z "$2" ]]; then
        print "当前阈值: ${BARK_THRESHOLD}秒"
        return 0
      fi
      [[ "$2" == <-> ]] || {
        print "阈值必须是正整数秒数" >&2
        return 1
      }
      export BARK_THRESHOLD="$2"
      print "Bark 通知阈值已设置为: ${BARK_THRESHOLD}秒"
      ;;
    ignore)
      case "${2:-}" in
        ""|help|-h|--help)
          print "用法:"
          print "  bark ignore list"
          print "  bark ignore add <前缀>"
          print "  bark ignore remove <前缀>"
          ;;
        list)
          _bark_print_ignore_list
          ;;
        add)
          shift 2
          _bark_ignore_add "$@"
          ;;
        remove)
          shift 2
          _bark_ignore_remove "$@"
          ;;
        *)
          print "未知的 ignore 子命令: $2" >&2
          return 1
          ;;
      esac
      ;;
    *)
      print "未知子命令: $cmd" >&2
      print ""
      _bark_print_help
      return 1
      ;;
  esac
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _bark_preexec
add-zsh-hook precmd _bark_precmd
