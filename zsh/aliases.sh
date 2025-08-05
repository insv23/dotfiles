source ~/.dotfiles/zsh/aliases/network.sh
source ~/.dotfiles/zsh/aliases/file_dir.sh
source ~/.dotfiles/zsh/aliases/bark_notify.zsh
source ~/.dotfiles/zsh/aliases/ssh.sh
source ~/.dotfiles/zsh/aliases/vscode-backup.sh
source ~/.dotfiles/zsh/aliases/ffmpeg.sh
source ~/.dotfiles/zsh/aliases/code-remote.sh

# PATH 分行显示
alias echopath='echo $PATH | tr ":" "\n"'

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
alias re='exec zsh'
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
  # 1. 记录当前工作目录
  local current_dir=$(pwd)

  # 2. 切换到 ~/.dotfiles 目录
  cd ~/.dotfiles || {
    echo "错误：无法进入 ~/.dotfiles 目录。" >&2
    return 1
  }

  # 3. 执行 git pull --ff-only
  git pull --ff-only || {
    echo "错误：git pull --ff-only 执行失败。" >&2
    cd "$current_dir"  # 失败时返回之前目录
    return 1
  }

  # 4. 执行 ./install (假设 install 脚本在 ~/.dotfiles 目录下)
  ./install || {
    echo "错误：./install 执行失败。" >&2
    cd "$current_dir" # 失败时返回之前目录
    return 1
  }

  # 5. 成功提示、返回原目录并重新加载 shell
  echo "dotfiles 已成功更新！正在重新加载 shell..."
  cd "$current_dir"
  exec zsh
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


# ---- Tmux ----
alias tmat='tmux new-session -A -s'   # new-session：创建一个新的 tmux 会话。
                                      # -A：如果指定名称的会话已经存在，则附加到该会话（而不是创建新会话）。
                                      # -s：指定会话的名称。
alias tmkt='tmux kill-session -t'


# ---- zellij ----
alias zj='zellij ls'
alias zja='zellij attach --create' # 如果已有 session, 就 attach 上; 如果没有则创建
alias zjd='zellij delete-session --force'


# ---- yazi ----
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


# Enhanced sleepto for immediate execution
function sleepto() {
    if [ -z "$1" ]; then
        echo "用法: sleepto HH:MM && command"
        echo "示例: sleepto 14:30 && echo 'Time reached!'"
        return 1
    fi
    
    local target_time="$1"
    
    # Validate time format
    if ! echo "$target_time" | grep -qE '^[0-2][0-9]:[0-5][0-9]$'; then
        echo "错误: 时间格式应为 HH:MM (24小时制)"
        return 1
    fi
    
    local current_epoch=$(date +%s)
    local target_epoch=$(date -j -f "%H:%M" "$target_time" "+%s" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "错误: 无效的时间格式"
        return 1
    fi
    
    # If target time is earlier than current time, assume it's for tomorrow
    if [ $target_epoch -le $current_epoch ]; then
        target_epoch=$((target_epoch + 86400))  # Add 24 hours
        echo "目标时间已过，将在明天 $target_time 执行"
    else
        echo "将在今天 $target_time 执行"
    fi
    
    local sleep_seconds=$((target_epoch - current_epoch))
    
    echo "等待 $sleep_seconds 秒 ($(($sleep_seconds / 3600))h $(($sleep_seconds % 3600 / 60))m $(($sleep_seconds % 60))s)"
    sleep $sleep_seconds
}

# ----- Cursor -----
# 在 crusor 中打开 command palette 搜索 `install cursor command`
alias cr='cursor'