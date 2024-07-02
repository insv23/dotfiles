# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# vim style 
set -o vi

# vim as default editor
export EDITOR='vim'

# 保证 ls 普通文件/目录/可执行文件/链接文件等显示不同的颜色
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# 设置系统语言环境为美式英语, 字符编码为 UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

source ~/.zsh/aliases.sh
source ~/.zsh/mac_aliases.sh
source ~/.zsh/macmini.local.zshrc
# source ~/.zsh/lz-ycy.local.zshrc
# source ~/.zsh/proxy.sh

source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# Load pyenv-virtualenv automatically
eval "$(pyenv virtualenv-init -)"

# zoxide
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"

# autin
eval "$(atuin init zsh)"

# MUST be sourced at the END of the .zshrc file
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

