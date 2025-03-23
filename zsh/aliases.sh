source ~/.dotfiles/zsh/aliases.network.sh
source ~/.dotfiles/zsh/aliases.file_dir.sh

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
ssh-ck () {
	if [ -z "$1" ]
	then
		echo "用法："
		echo "  ssh-ck server_<服务器名称>@<服务器用户>   # 生成连接到特定服务器的密钥"
		echo "  ssh-ck github_<GitHub账户>             # 生成连接到GitHub账户的密钥"
		return 1
	fi
	user_host=$(whoami)@$(hostname)
	key_name="$HOME/.ssh/$1"
	ssh-keygen -f "$key_name" -t rsa -N '' -C "$user_host to $1"

	# 使用 pbcopy 复制公钥到剪贴板 (仅限 macOS)
	if [[ "$OSTYPE" == "darwin"* ]]; then
		pbcopy < "$key_name.pub"
		echo "公钥已复制到剪贴板。"
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		# Linux 下尝试使用 xclip 或 xsel (需要安装)
		if command -v xclip >/dev/null 2>&1; then
			xclip -selection clipboard < "$key_name.pub"
			echo "公钥已复制到剪贴板 (使用 xclip)。"
		elif command -v xsel >/dev/null 2>&1; then
			xsel --clipboard --input < "$key_name.pub"
			echo "公钥已复制到剪贴板 (使用 xsel)。"
		else
			echo "无法复制公钥到剪贴板。请手动复制 $key_name.pub 的内容。"
		fi
	else
		echo "无法复制公钥到剪贴板。请手动复制 $key_name.pub 的内容。"
	fi
}


# kitty `kitten ssh`
## 目前我体会到的唯一优势是: 新建 Kitty window, 会是服务器的；普通 ssh 是本地的终端
## 但没有断开自动重连能力，所以还是更倾向使用下面的 autossh
# alias s="kitten ssh"


# 使用密码连接(不会自动重连)
# 密码存储在环境变量中: export SSH_PW_主机名='密码'
function ap() {
  local host="$1"
  local password_var="SSH_PW_${host}"
  local password

  if [ -z "$host" ]; then
    echo "使用密码连接，密码存储在环境变量中: export SSH_PW_主机名='密码'"
    echo "用法: ap 主机"
    echo "主机需要在 ~/.ssh/config 中配置"
    return 1
  fi

  # 使用关联数组 (hash) 模拟间接引用
  typeset -A var_map
  var_map[$password_var]="${(P)password_var}"  # 使用 (P) 参数展开标志
  password=${var_map[$password_var]}

  if [ -z "$password" ]; then
    echo "错误：未找到 ${password_var} 环境变量，请先设置该变量。"
    return 1
  fi

  sshpass -p "$password" ssh "$host"
}


# ---- audossh ----
# 使用密钥对连接
function ak() {
  # 检查是否提供了参数
  if [ $# -eq 0 ]; then
    echo "使用密钥对连接"
    echo "用法：ak 主机"
    echo "主机需要在 ~/.ssh/config 中配置，且需配置 key"
    return 1
  fi

   # 断开将自动重连: 每 30 秒发送一次心跳，最多允许 3 次重试
   autossh -M 0 \
       -o "ServerAliveInterval 30" \
       -o "ServerAliveCountMax 3" \
       "$@"
}


# ---- zellij ----
alias zj='zellij ls'
alias zja='zellij attach --create' # 如果已有 session, 就 attach 上; 如果没有则创建
alias zjd='zellij delete-session --force'

