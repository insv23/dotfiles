# 别名加载器：依次 source aliases/ 下的所有模块，并定义杂项函数
# =============================================================================
# aliases.sh — 全局别名与函数入口
#
# 结构：
#   - 顶部 source 各分类模块（网络、文件、SSH 等）
#   - 下方直接定义通用/零散的别名和函数
# =============================================================================


# ---- 分类模块 ----
# 各模块放在 ~/.dotfiles/zsh/aliases/ 目录下独立维护
source ~/.dotfiles/zsh/aliases/fzf.zsh           # fzf 模糊查找组合命令（fbrs、fkill、fgco 等）
source ~/.dotfiles/zsh/aliases/network.zsh       # 网络相关工具（ping、curl、端口检查等）
source ~/.dotfiles/zsh/aliases/files.zsh         # 文件与目录操作
source ~/.dotfiles/zsh/aliases/bark.zsh          # Bark 推送通知（iOS 消息提醒）
source ~/.dotfiles/zsh/aliases/ssh.zsh           # SSH 快捷连接与管理
source ~/.dotfiles/zsh/aliases/vscode-backup.zsh # VS Code 配置备份
source ~/.dotfiles/zsh/aliases/claude.zsh        # Claude Code CLI 快捷命令
source ~/.dotfiles/zsh/aliases/vscode-remote.zsh # 远程开发连接相关
source ~/.dotfiles/zsh/aliases/log.zsh           # 带日志输出的命令运行工具
source ~/.dotfiles/zsh/aliases/tts.zsh           # 文字转语音（TTS）
source ~/.dotfiles/zsh/aliases/clipboard.zsh     # 剪贴板粘贴相关工具


# ---- 系统工具 ----

# 显示文件或路径的绝对路径（类似 pwd，但针对具体文件）
alias pwf='realpath'

# 将 PATH 每个路径分行显示，方便排查路径问题
alias echopath='echo $PATH | tr ":" "\n"'

# grep 默认开启颜色高亮
alias grep='grep --color'


# ---- Git ----

# 用 ag（silver searcher）在 git 仓库中搜索
alias gag='git exec ag'

# 设置当前仓库的 git 用户信息为 insv
alias ginsv='git config user.name "insv";git config user.email "insv23@outlook.com"'

# 设置全局 git 用户信息为 insv
alias gginsv='git config --global user.name "insv";git config --global user.email "insv23@outlook.com"'

# 跳转到当前 git 仓库的根目录
alias cdgr='cd "$(git root)"'

# 从 gitignore.io 生成 .gitignore 模板，如：gi python node >> .gitignore
function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@; }

# 打开 lazygit TUI
alias lg='lazygit'


# ---- Zsh ----

# 用新 zsh 进程替换当前 shell（完整重启，会重新加载所有配置）
alias rezsh='exec zsh'
alias re='exec zsh'

# 重新 source zshrc（不重启进程，适合快速热更新配置）
alias szsh='source ~/.zshrc'

# 退出当前 shell
alias e=exit


# ---- Homebrew ----

# 搜索包（提示：fbrs 可直接在 fzf 中浏览并安装，无需分两步）
brs() { echo "💡 试试 fbrs：fzf 交互选择 + 直接安装，一步到位"; brew search "$@"; }

# 安装 formula（提示：fbrs 可代替 brs + bri 两步操作）
bri() { echo "💡 试试 fbrs：fzf 交互选择 + 直接安装，一步到位"; brew install "$@"; }

# 安装 cask（GUI 应用，fbrs 同样支持 cask）
bric() { echo "💡 试试 fbrs：fzf 同时列出 formulae 和 casks"; brew install --cask "$@"; }

# 查看包信息
alias bro='brew info'
# 升级所有已安装的包
alias brup='brew upgrade'
# 强制卸载（不检查依赖）
alias brui='brew uninstall --force'


# ---- Dotfiles ----

# 拉取最新 dotfiles 并重新执行安装脚本，完成后重启 shell
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


# ---- Python ----

# python 简写
alias py='python'
# 以模块方式运行，如：pym http.server 8080
alias pym='py -m'


# ---- Caddy ----

# 编辑 Caddyfile → 自动格式化 → 重载服务（三步合一，任一步失败即中止）
caddy_edit_format_reload() {
    local caddyfile="/etc/caddy/Caddyfile"

    # 1. 编辑配置文件
    sudo vim "$caddyfile" || return 1

    # 2. 格式化配置文件
    sudo caddy fmt --overwrite "$caddyfile" || return 1

    # 3. 重新加载 Caddy 服务
    sudo systemctl reload caddy
}


# ---- Docker ----

# 打开 lazydocker TUI
alias ld='lazydocker'

# docker compose 简写
alias dc='docker compose'
# 停止并移除容器（保留镜像和数据卷）
alias dcd='docker compose down'
# 启动服务（前台，显示日志）
alias dcu='docker compose up'
# 启动服务（后台 detached 模式）
alias dcud='docker compose up -d'

# 列出所有容器，显示名称、ID、镜像、状态、端口等详细信息
alias dcls='docker container ls --format "table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}"'


# ---- Tmux ----

# 创建或附加到指定名称的会话，如：tmat work
alias tmat='tmux new-session -A -s'
# 关闭指定会话，如：tmkt work
alias tmkt='tmux kill-session -t'
# 列出所有会话
alias tmls='tmux ls'


# ---- Zellij ----

# 列出所有 zellij 会话
alias zj='zellij ls'
# 附加到已有会话，不存在则新建
alias zja='zellij attach --create'
# 强制删除指定会话
alias zjd='zellij delete-session --force'


# ---- Yazi ----

# 打开 yazi 文件管理器，退出后自动 cd 到 yazi 内最后所在的目录
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# y 是 yy 的短别名（同上）
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}


# ---- 定时执行 ----

# 阻塞等待到指定时间点后继续，配合 && 使用，如：sleepto 14:30 && say "时间到"
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


# ---- Cursor ----

# 用 Cursor 编辑器打开文件或目录（需先在编辑器内执行 install cursor command）
alias cr='cursor'
