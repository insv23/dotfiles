# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# vim mode
set -o vi

# 保证 ls 普通文件/目录/可执行文件/链接文件等显示不同的颜色
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

source ~/.zsh/aliases.sh
source ~/.zsh/mac_aliases.sh
# source ~/.zsh/proxy.sh

source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme

source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# Load pyenv-virtualenv automatically
eval "$(pyenv virtualenv-init -)"

export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"

eval "$(atuin init zsh)"

export PATH="$PATH:/opt/nvim-linux64/bin"

# MUST be sourced at the END of the .zshrc file
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
