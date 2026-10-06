# ZLE 配置：自定义 Zsh 行编辑器快捷键
# ---- ZLE 快捷键配置 ----
# 基于 emacs 模式，复杂编辑用 Ctrl-G 进入 vim
#
# 快捷键速查:
#   ^A  行首
#   ^E  行尾
#   ^F  删除到上一个目录层级
#   ^D  清空引号内容
#   ^G  进入 vim 编辑
#   ^X  复制并清空完整输入缓冲区
# -------------------------

bindkey -e # 使用 emacs 模式

# ^A ^E: 行首/行尾 (emacs 内置，无需额外绑定)

# Tab: 接受 zsh-autosuggestions 的灰色建议；Tab Tab: 触发 fzf --zsh 的补全
bindkey '^I' autosuggest-accept
bindkey '^I^I' fzf-completion

# ^X: 复制完整输入后清空；仅在 pbcopy 成功时才删除，避免剪贴板失败导致内容丢失。
copy-and-clear-buffer () {
    local input=$BUFFER
    if print -rn -- "$input" | pbcopy; then
        BUFFER=''
        CURSOR=0
    else
        zle beep
        return 1
    fi
}
zle -N copy-and-clear-buffer
bindkey '^x' copy-and-clear-buffer

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
        local ch=${LBUFFER:$i:1}
        if [[ $ch == '"' || $ch == "'" ]]; then
            if (( i == 0 )) || [[ ${LBUFFER:$((i-1)):1} != '\\' ]]; then
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
        local ch=${RBUFFER:$i:1}
        if [[ $ch == "$quote" ]]; then
            if (( i == 0 )) || [[ ${RBUFFER:$((i-1)):1} != '\\' ]]; then
                close_idx=$i
                break
            fi
        fi
    done

    if (( close_idx == -1 )); then
        zle beep
        return 1
    fi

    LBUFFER="${LBUFFER:0:$((open_idx+1))}"
    RBUFFER="${RBUFFER:$close_idx}"
}
zle -N clear-quote-content
bindkey '^d' clear-quote-content

# accept-line: 回车前清除缓冲区开头全部空白（空格、Tab、粘贴带进来的前导空行）。
# 粘贴命令常带前导空白，而 atuin 把空白开头的命令整条丢弃不记录，历史搜不到。
# ponytail: 前导空白一律清除，无例外；若 heredoc 正文恰好是当前缓冲区且以缩进开头，该缩进会丢失，升级条件是用户真的需要保留 heredoc 首行缩进。
accept-line () {
    setopt localoptions extendedglob
    BUFFER="${BUFFER##[[:space:]]#}"
    zle .accept-line
}
zle -N accept-line

# ^G: 进入 vim 编辑当前命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^g' edit-command-line
