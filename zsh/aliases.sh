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
source ~/.dotfiles/zsh/aliases/vim.zsh           # Vim/vi 草稿工作流
source ~/.dotfiles/zsh/aliases/bark.zsh          # Bark 推送通知（iOS 消息提醒）
source ~/.dotfiles/zsh/aliases/ssh.zsh           # SSH 快捷连接与管理
source ~/.dotfiles/zsh/aliases/vscode-backup.zsh # VS Code 配置备份
source ~/.dotfiles/zsh/aliases/vscode-remote.zsh # 远程开发连接相关
source ~/.dotfiles/zsh/aliases/log.zsh           # 带日志输出的命令运行工具
source ~/.dotfiles/zsh/aliases/tts.zsh           # 文字转语音（TTS）
source ~/.dotfiles/zsh/aliases/clipboard.zsh     # 剪贴板粘贴相关工具
source ~/.dotfiles/zsh/aliases/codename.zsh      # 随机项目代号生成器（如 DH-09）


# ---- 系统工具 ----

# grep 默认开启颜色高亮
alias grep='grep --color'


# ---- Git ----

# 从 gitignore.io 生成 .gitignore 模板，如：gi python node >> .gitignore
function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@; }


# ---- Homebrew ----

brew() {
  if [[ "${1-}" == "upgrade" ]]; then
    shift
    local has_named_target=0
    local arg

    for arg in "$@"; do
      [[ "$arg" == -* ]] || {
        has_named_target=1
        break
      }
    done

    if [[ "$has_named_target" -eq 0 ]]; then
      echo "全量 brew upgrade 已禁用。请使用 brew upgrade <包名> 或 fbrup。"
      return 1
    fi

    set -- upgrade "$@"
  fi

  command brew "$@"
}

# 搜索包（提示：fbrs 可直接在 fzf 中浏览并安装，无需分两步）
brs() { echo "💡 试试 fbrs：fzf 交互选择 + 直接安装，一步到位"; brew search "$@"; }

# 安装 formula（提示：fbrs 可代替 brs + bri 两步操作）
bri() { echo "💡 试试 fbrs：fzf 交互选择 + 直接安装，一步到位"; brew install "$@"; }

# 安装 cask（GUI 应用，fbrs 同样支持 cask）
bric() { echo "💡 试试 fbrs：fzf 同时列出 formulae 和 casks"; brew install --cask "$@"; }

# 定向升级入口：全量升级已禁用
brup() {
  echo "全量 brew upgrade 已禁用。请使用 fbrup 或 brew upgrade <包名>。"
  return 1
}


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
