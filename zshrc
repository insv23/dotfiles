# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet # 当主题加载时保持安静，不显示警告信息 

source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme


# ---- zsh-completions ----
# 一个补全规则的集合, 提供了各种命令、选项、文件名、目录名、变量名等的补全规则。
# 支持的列表: https://github.com/zsh-users/zsh-completions/tree/master/src
fpath=(~/.zsh/plugins/zsh-completions/src $fpath)


# ---- zsh-autosuggestions ----
# 在你输入命令时，zsh-autosuggestions 会根据你的历史命令记录，在你输入的位置之后，以灰色文本显示建议的命令。
# 演示: https://asciinema.org/a/37390
# 使用右方向键接受整个, 可与 vi 联合使用, 逐个字母/单词的接受建议
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


# ---- zsh-syntax-highlighting ----
# 可执行命令是 绿色的, 不可执行命令是 红色的
# MUST be sourced at the END of the .zshrc file
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# ---- zsh-autocomplete ----
# 必须将 autocomplete 放在 syntax-highlighting 下才能让新建 zsh 不再出现样式警告
# 参考: https://github.com/zsh-users/zsh-syntax-highlighting/issues/951#issuecomment-2089829937
# 按下 下方向键 展示所有可选
# cd 的自动补全效果一般，按下 tab 就把第一个补上了... 因此更推荐使用 z 直接跳转 或 yazi
# https://www.notion.so/zsh-53922bbbd4f74a8f961a3010f541845a?pvs=4#8723929e12c1463998b9dded920ab0b1
source ~/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh



# ---- 自定义激活----
source ~/.zsh/aliases.sh

source ~/.zsh/hosts/local_index.sh

# fzf 还是用不太习惯
# 使用参考: https://www.notion.so/fzf-b15582832ee449dbbec50c0b0481852b?pvs=4
# `任何命令 **Tab`: 触发 fzf 的模糊查找，并将其结果作为命令的参数
# 例如: 
# cd **Tab：会列出当前目录下的所有文件和目录。
# vim **Tab：会列出当前目录下的所有文件。
## (或者 cd/vim/以及其他操纵文件的命令 ctrl t, 因为 ctrl t 是模糊查找工作目录下的所有文件和子目录，并将选择输出到标准输出。)
# kill **Tab: 杀死进程
source ~/.dotfiles/zsh/fzf.zshrc

source ~/.dotfiles/zsh/zle.zsh


# ---- kitty 设置窗口标题 ----
precmd() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        echo -ne "\033]0;${HOST}:${PWD##*/}\007"
    else
        echo -ne "\033]0;${PWD##*/}\007"
    fi
}


# ---- autin ----
# 放在 fzf 和 auto-complete 下面才能保证 上方向键 和 Ctrl r 使用 atuin 来查找历史命令 
eval "$(atuin init zsh)"

# ---- direnv -----
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""     # 关闭 direnv 加载信息，使其不出现在终端中

# ---- zoxide ----
eval "$(zoxide init zsh)"