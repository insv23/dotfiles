# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme

# 演示: https://asciinema.org/a/37390
# 使用右方向键接受整个, 可与 vi 联合使用, 逐个字母/单词的接受建议
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh



# ----- 根据主机名选择相应的配置文件 -----

# 获取当前主机名
current_hostname=$(hostname)

case "$current_hostname" in
  "macmini")
    source ~/.zsh/hosts/macmini.local.zshrc
    ;;
  "mba")
    source ~/.zsh/hosts/mba.local.zshrc
    ;;
  "Babel")
    source ~/.zsh/hosts/Babel.local.zshrc
    ;;
  "C20240108106238")
    source ~/.zsh/hosts/lz-ycy.local.zshrc
    ;;
  *)
    # 默认配置，如果没有匹配的主机名
    echo "No specific configuration for this hostname. Please create a new one in ~/.dotfiles/zsh/hosts/"
    ;;
esac


source ~/.zsh/aliases.sh


# vim style 
set -o vi

# vim as default editor
export EDITOR='vim'


# 设置系统语言环境为美式英语, 字符编码为 UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8


# asdf
source $(brew --prefix asdf)/libexec/asdf.sh


# zoxide
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"

# yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}


# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)


# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


# -- fzf preview --

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# -- fzf-git --
# https://github.com/junegunn/fzf-git.sh
source ~/.zsh/plugins/fzf-git.sh/fzf-git.sh


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
