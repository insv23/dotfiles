#!/bin/sh

# 检查是否为 ARM Linux，如果是则退出
if uname -a | grep -q "Linux" && uname -m | grep -q "aarch64"; then
    echo "🚫 ARM Linux 暂不支持 Homebrew，退出安装 apps..."
    exit 0
fi

# 根据系统添加 Homebrew 路径
if uname -a | grep -q "Darwin"; then
    # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "🍏 brew 安装 mac apps..."
    brew bundle --file=~/.dotfiles/brew/Brewfile.mac
else
    # Linux (x86_64)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "🐧 brew 安装 linux apps..."
    brew bundle --file=~/.dotfiles/brew/Brewfile.linux
fi

# 安装通用应用
echo "🍺 brew 安装通用 apps..."
brew bundle --file=~/.dotfiles/brew/Brewfile.both