# ---- ZLE 快捷键配置 ----
# 基于 emacs 模式，复杂编辑用 Ctrl-V 进入 vim
#
# 快捷键速查:
#   ^A  行首
#   ^E  行尾
#   ^F  删除到上一个目录层级
#   ^D  清空引号内容
#   ^V  进入 vim 编辑
# -------------------------

bindkey -e # 使用 emacs 模式

# ^A ^E: 行首/行尾 (emacs 内置，无需额外绑定)

# ^F: 删除光标左侧的一个目录层级
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
    zle -f kill
}
zle -N backward-kill-dir
bindkey '^f' backward-kill-dir

# ^D: 清空当前引号内的内容，保留空引号
clear-quote-content () {
    local quote
    local -i open_idx=-1 close_idx=-1 i

    for (( i=${#LBUFFER}-1; i>=0; i-- )); do
        local ch=${LBUFFER:i:1}
        if [[ $ch == '"' || $ch == "'" ]]; then
            if (( i == 0 || ${LBUFFER:i-1:1} != '\\' )); then
                quote=$ch
                open_idx=$i
                break
            fi
        fi
    done

    if (( open_idx == -1 )); then
        zle beep
        return 1
    fi

    for (( i=0; i<${#RBUFFER}; i++ )); do
        local ch=${RBUFFER:i:1}
        if [[ $ch == "$quote" ]]; then
            if (( i == 0 || ${RBUFFER:i-1:1} != '\\' )); then
                close_idx=$i
                break
            fi
        fi
    done

    if (( close_idx == -1 )); then
        zle beep
        return 1
    fi

    LBUFFER="${LBUFFER:0:open_idx+1}"
    RBUFFER="${RBUFFER:close_idx}"
}
zle -N clear-quote-content
bindkey '^d' clear-quote-content

# ^V: 进入 vim 编辑当前命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^v' edit-command-line
