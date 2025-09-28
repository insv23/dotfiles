#!/bin/sh

# ----- Constants -----
LINUX_BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
MACOS_BREW_PATH="/opt/homebrew/bin/brew"
BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# 获取系统相关信息
# Get system information
get_system_info() {
    OS_TYPE="$(uname)"
    ARCH_TYPE="$(uname -m)"
}

# 根据系统类型确定 brew 路径
# Determine brew path based on OS
get_brew_path() {
    if [ "$OS_TYPE" = "Darwin" ]; then
        echo "$MACOS_BREW_PATH"
    else
        echo "$LINUX_BREW_PATH"
    fi
}

# 检查系统兼容性
# Check system compatibility
check_system_compatibility() {
    # homebrew 目前不支持 ARM 架构的 Linux
    # Homebrew on Linux is not supported on ARM processors
    if [ "$OS_TYPE" = "Linux" ] && [ "$ARCH_TYPE" = "aarch64" ]; then
        echo "⛔ Homebrew on Linux is not supported on ARM processors."
        echo "https://docs.brew.sh/Homebrew-on-Linux#arm-unsupported"
        return 1
    fi
    return 0
}

# 检查 brew 是否已安装且正常工作
# Check if brew is installed and working
check_brew_installation() {
    local brew_path="$1"
    if [ -x "$brew_path" ] && "$brew_path" --version >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# 安装 Homebrew
# Install Homebrew
install_homebrew() {
    echo "🚀 Homebrew is not installed or not working, installing..."
    if /bin/bash -c "$(curl -fsSL $BREW_INSTALL_URL)"; then
        echo "🎉 Homebrew is installed successfully"
        return 0
    else
        echo "❌ Failed to install Homebrew"
        return 1
    fi
}

# 配置 Homebrew 自动更新（macOS 使用 brew-autoupdate；Linux 使用 cron）
# Configure Homebrew auto-update (macOS via brew-autoupdate; Linux via cron)
setup_brew_autoupdate() {
    local brew_path="$1"

    if [ "$OS_TYPE" = "Darwin" ]; then
        echo "⚙️  Checking Homebrew autoupdate status on macOS..."
        status_output="$("$brew_path" autoupdate status 2>&1 || true)"
        if printf "%s" "$status_output" | grep -qi "installed and running"; then
            echo "✅ Homebrew autoupdate is already running. Skipping."
            return 0
        fi

        echo "⚙️  Enabling Homebrew autoupdate on macOS..."
        # 安装并启动 autoupdate，每 86400 秒（24 小时）执行一次
        "$brew_path" tap domt4/autoupdate >/dev/null 2>&1 || true
        if "$brew_path" autoupdate start 86400 >/dev/null 2>&1; then
            echo "Homebrew will now automatically update every 24 hours."
        else
            echo "ℹ️  Attempted to start Homebrew autoupdate (check manually with: brew autoupdate status)"
        fi
    else
        echo "⚙️  Enabling Homebrew autoupdate on Linux via cron..."
        if command -v crontab >/dev/null 2>&1; then
            CRON_LINE="30 3 * * * /bin/bash -lc 'eval \"\$("$LINUX_BREW_PATH" shellenv)\" && brew update'"

            # 如果已存在我们的标识性注释，则认为任务已添加
            if crontab -l 2>/dev/null | grep -F "Linux Homebrew 每天 03:30 自动更新一次Homebrew 自身和索引" >/dev/null 2>&1; then
                echo "✅ Cron entry for Homebrew update already present."
            else
                # 保留已有任务并追加我们的任务
                (crontab -l 2>/dev/null; \
                  echo "# Linux Homebrew 每天 03:30 自动更新一次Homebrew 自身和索引"; \
                  echo "$CRON_LINE") | crontab -
                if [ "$?" -eq 0 ]; then
                    echo "✅ Added cron job: daily 03:30 Homebrew update"
                else
                    echo "❌ Failed to add cron job for Homebrew update"
                fi
            fi
        else
            echo "❌ 'crontab' not found. Please install cron or set up updates manually."
            echo "   Hint: crontab -e → add:"
            echo "   30 3 * * * /bin/bash -lc 'eval \"\$("$LINUX_BREW_PATH" shellenv)\" && brew update'"
        fi
    fi
}

# 主函数
# Main function
main() {
    get_system_info
    
    # 如果返回 1（系统不兼容），就会执行 exit 1(直接退出, 不执行后续几行命令)
    check_system_compatibility || exit 1
    
    BREW_PATH=$(get_brew_path)
    
    if check_brew_installation "$BREW_PATH"; then
        echo "✅ Homebrew is installed and working"
    else
        install_homebrew
    fi

    if check_brew_installation "$BREW_PATH"; then
        setup_brew_autoupdate "$BREW_PATH"
    fi
    
    echo
}

# 执行主函数
# Execute main function
main
