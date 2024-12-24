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
    
    echo
}

# 执行主函数
# Execute main function
main
