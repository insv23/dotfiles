# ---- 终端命令编辑模式 ----
bindkey -v  # 键盘绑定模式设置为 viins 模式
# 按下 ESC 后更快切换到命令模式
export KEYTIMEOUT=1 # 设置为 0.1 秒(默认是 0.4 秒)

# 编辑模式下, 使用 ctrl v, 使用 nvim(默认编辑器) 编辑当前命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^v' edit-command-line
bindkey -M vicmd '^v' edit-command-line  # 添加 normal 模式下的绑定

# 删除光标左侧的一个目录层级, 相当于 bash 的 unix-filename-rubout
# 效果和 ctrl w 差不多，但这个删除的会多一点
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
    zle -f kill
}
zle -N backward-kill-dir
bindkey '^f' backward-kill-dir

# Emacs 键位, ctrl a/e 到开头结尾
bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^e' end-of-line