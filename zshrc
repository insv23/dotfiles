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

# ---- zsh-autosuggestions ----
# 演示: https://asciinema.org/a/37390
# 使用右方向键接受整个, 可与 vi 联合使用, 逐个字母/单词的接受建议
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


source ~/.zsh/aliases.sh

source ~/.zsh/hosts/local_index.sh


# ---- kitty 设置窗口标题 ----
precmd() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        echo -ne "\033]0;${HOST}:${PWD##*/}\007"
    else
        echo -ne "\033]0;${PWD##*/}\007"
    fi
}



# ---- 终端命令编辑模式 ----
set -o vi

# ---- asdf ----
source $(brew --prefix asdf)/libexec/asdf.sh

# ---- direnv -----
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""     # 关闭 direnv 加载信息，使其不出现在终端中


# ---- zoxide ----
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"



# MUST be sourced at the END of the .zshrc file
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# 必须将 autocomplete 放在 syntax-highlighting 下才能让新建 zsh 不再出现样式警告
# https://github.com/zsh-users/zsh-syntax-highlighting/issues/951#issuecomment-2089829937
# 按下 下方向键 展示所有可选
# https://www.notion.so/zsh-53922bbbd4f74a8f961a3010f541845a?pvs=4#8723929e12c1463998b9dded920ab0b1
source ~/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh


# 放在 fzf 和 auto-complete 下面才能保证 上方向键 和 Ctrl r 使用 atuin 来查找历史命令 
# autin
eval "$(atuin init zsh)"
