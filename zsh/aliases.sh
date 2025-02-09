source ~/.dotfiles/zsh/aliases.network.sh
source ~/.dotfiles/zsh/aliases.file_dir.sh

# PATH 分行显示
alias echo_path='echo $PATH | tr ":" "\n"'

# grep
alias grep='grep --color'

# git 
# in `../gitconfig`
alias gag='git exec ag'
alias ginsv='git config user.name "insv";git config user.email "insv23@outlook.com"'
alias gginsv='git config --global user.name "insv";git config --global user.email "insv23@outlook.com"'
# cd to git root directory
alias cdgr='cd "$(git root)"'
# create .gitignore template
function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@; }
alias lg='lazygit'

# zsh
alias rezsh='exec zsh' # 用一个新的 Zsh 实例替换当前的 Zsh 进程，相当于“重启”了 Zsh。
alias szsh='source ~/.zshrc'
alias e=exit

# Homebrew
alias brs='brew search'
alias bri='brew install'
alias bric='brew install --cask'
alias bro='brew info'
alias bru='brew uninstall'

# nvim
alias nv='nvim'

# Update dotfiles
dfu() {
  (
    cd ~/.dotfiles && git pull --ff-only
  )
}

# python
alias py='python'
alias pym='py -m'

# ---- caddy ----
alias caddy_edit_format_reload='sudo -E nvim /etc/caddy/Caddyfile && sudo caddy fmt --overwrite /etc/caddy/Caddyfile && sudo systemctl reload caddy'

# ---- Docker ----
alias ld='lazydocker'

alias dc='docker compose'
alias dcd='docker compose down'
alias dcu='docker compose up'
alias dcud='docker compose up -d'

# 展示所有容器, 第一列是容器名字
alias dcls='docker container ls --format "table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}"'




# Tmux
alias tmat='tmux new-session -A -s'   # new-session：创建一个新的 tmux 会话。
                                      # -A：如果指定名称的会话已经存在，则附加到该会话（而不是创建新会话）。
                                      # -s：指定会话的名称。
alias tmkt='tmux kill-session -t'


# yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# 创建 ssh 密钥(默认无密码)
ssh-ck() {
    if [ ! -z "$1" ]; then
        user_host=$(whoami)@$(hostname)
        ssh-keygen -f $HOME/.ssh/$1 -t rsa -N '' -C "$user_host to $1"
    fi
}
