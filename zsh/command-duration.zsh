# 命令耗时行：在提示符之前打印上一条命令的耗时，让它紧贴自己的输出。
#
# 不用 p10k 的 command_execution_time segment：segment 只能落在提示符自身的行里，
# 而虚线（POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR）只在提示符首行生效，
# 把耗时塞进首行会连虚线一起搬上去。前提是 p10k.zsh 的左右元素列表里都没有
# command_execution_time，否则会重复显示。

autoload -Uz add-zsh-hook
zmodload zsh/datetime

# 低于这个秒数不显示。
: ${COMMAND_DURATION_THRESHOLD:=3}
# Nerd Font 沙漏 U+F252，即 p10k nerdfont-v3 模式下该 segment 的内置图标。
: ${COMMAND_DURATION_ICON:=$'\uF252'}
: ${COMMAND_DURATION_COLOR:=101}

_command_duration_preexec() {
  _command_duration_start=$EPOCHREALTIME
}

_command_duration_precmd() {
  # 先存住 $?：算术和条件测试会改写它，而 p10k 的 status segment 在后面的
  # precmd hook 里读 $?。
  local ret=$?
  [[ -n ${_command_duration_start:-} ]] || return $ret

  # 与 p10k 一致：整数赋值截断，所以加 0.5 做四舍五入。
  local -i total=EPOCHREALTIME-_command_duration_start+0.5
  unset _command_duration_start
  (( total >= COMMAND_DURATION_THRESHOLD )) || return $ret

  local text
  if (( total < 60 )); then
    text="${total}s"
  elif (( total < 3600 )); then
    text="$((total / 60))m $((total % 60))s"
  elif (( total < 86400 )); then
    text="$((total / 3600))h $((total / 60 % 60))m $((total % 60))s"
  else
    text="$((total / 86400))d $((total / 3600 % 24))h $((total / 60 % 60))m $((total % 60))s"
  fi

  print -P "%F{${COMMAND_DURATION_COLOR}}${COMMAND_DURATION_ICON} ${text}%f"
  return $ret
}

add-zsh-hook preexec _command_duration_preexec
add-zsh-hook precmd _command_duration_precmd
