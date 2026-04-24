#!/bin/sh
# 初始化脚本：检查登录 shell 是否为 zsh，若不是则通过 chsh 切换

# ----- bash to zsh -----
current_shell=`which "$SHELL"`

if echo "$current_shell" | grep -q "zsh"; then
    zsh_version=`zsh --version | cut -d' ' -f2`
    echo "✅ Current shell is already zsh: $current_shell (version $zsh_version)"
    echo
else
    echo "⚠️ Current shell is not zsh. Checking if zsh is available..."

    if which zsh >/dev/null 2>&1; then
        zsh_path=`which zsh`
        zsh_version=`zsh --version | cut -d' ' -f2`
        echo "🔄 zsh($zsh_path version $zsh_version) is available. Attempting to switch to zsh..."
        sudo chsh -s "$zsh_path" "$LOGNAME"
        echo "🔔 Shell changed. Please log out and log back in for changes to take effect."
        echo
    else
        echo "❌ zsh is not installed or not in PATH. Please install zsh first."
        echo "💡 If Homebrew is installed, run:"
        echo "  brew install zsh"
        echo "  sudo chsh -s \"\`brew --prefix\`/bin/zsh\" \"\\\$LOGNAME\""
        echo "💡 On Ubuntu, run:"
        echo "  sudo apt update"
        echo "  sudo apt install zsh -y"
        echo "  sudo chsh -s \"\`which zsh\`\" \"\\\$LOGNAME\""
        echo
    fi

    echo "ℹ️ Current shell path is: $current_shell"
    echo
fi
