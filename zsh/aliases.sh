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


# SSH connect: try key first, then password from env var
function a() {
  local host="$1"
  local password_var="SSH_PW_${host}"
  local password
  local hostname
  local port

  if [ -z "$host" ]; then
    echo "用法: a 主机"
    echo "主机需要在 ~/.ssh/config 中配置"
    echo "根据主机 config 中是否有 IdentityFile 来判断是用密钥还是密码登录，如有则使用密钥登录，否则使用密码登录"
    return 1
  fi

  # 检查主机是否在 ssh config 中配置，并且获取该主机的配置块
  local host_config
  host_config=$(awk "/^Host[[:space:]]+${host}\$/{p=1;print;next} p&&/^Host[[:space:]]+/{p=0;exit} p{print}" ~/.ssh/config)
  
  if [ -z "$host_config" ]; then
    echo "错误：主机 $host 未在 ~/.ssh/config 中配置"
    echo "请先在 ~/.ssh/config 中添加配置"
    return 1
  fi

  # 从配置块中提取 HostName 和 Port
  hostname=$(echo "$host_config" | awk '/^[[:space:]]*HostName[[:space:]]+/ {print $2}')
  port=$(echo "$host_config" | awk '/^[[:space:]]*Port[[:space:]]+/ {print $2}')
  
  if [ -z "$hostname" ]; then
    echo "错误：无法从配置中获取 HostName"
    return 1
  fi

  # 检查是否是首次连接
  local known_host_pattern
  if [ -n "$port" ] && [ "$port" != "22" ]; then
    known_host_pattern="[$hostname]:$port"
  else
    known_host_pattern="$hostname"
  fi

  if ! ssh-keygen -F "$known_host_pattern" >/dev/null 2>&1; then
    echo "注意: 在新设备第一次连接时不能用，需要先用 ssh 连接上一次后才能用"
    echo "请先使用: ssh $host"
    return 1
  fi

  # 检查特定主机的配置块中是否有 IdentityFile
  if echo "$host_config" | grep -q "^[[:space:]]*IdentityFile"; then
    # 有 IdentityFile，使用 autossh 登录
    autossh -M 0 \
      -o "ServerAliveInterval 30" \
      -o "ServerAliveCountMax 3" \
      -o "BatchMode=yes" \
      "$host"
    return $?
  fi

  # 没有 IdentityFile，使用密码登录
  typeset -A var_map
  var_map[$password_var]="${(P)password_var}"
  password=${var_map[$password_var]}

  if [ -z "$password" ]; then
    echo "未找到 ${password_var} 环境变量。"
    echo -n "请输入 ${host} 的密码: "
    read input_password
    echo  # 换行
    
    if [ -z "$input_password" ]; then
      echo "错误：密码不能为空"
      return 1
    fi
    
    # 将密码保存到环境变量中，存储在 ~/.envrc 中
    echo "export ${password_var}=\"${input_password}\"" >> ~/.envrc && cd ~ && direnv allow
    
    # 更新当前环境变量，这样就不用退出重进
    export "${password_var}=${input_password}"
    
    # 尝试密码连接
    sshpass -p "$input_password" ssh "$host"
    return $?
  fi

  # 使用已存在的密码连接
  sshpass -p "$password" ssh "$host"
}
