#!/bin/sh

# 检查是否为 ARM Linux，如果是则退出
if uname -a | grep -q "Linux" && uname -m | grep -q "aarch64"; then
    echo "🚫 ARM Linux 暂不支持 Homebrew， 将退出 Homebrew 安装 apps..."
    exit 0
fi

# 根据系统添加 Homebrew 路径
if uname -a | grep -q "Darwin"; then
    # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    # Linux
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ----- Brew Install Apps-----
echo "🍺 brew 安装 mac 与 Linux 均使用的 apps..."
xargs brew install < ~/.dotfiles/brew/brew-both.txt
echo

if uname -a | grep -q "Darwin"; then
    echo "🍏 brew 安装 mac apps..."
    xargs brew install < ~/.dotfiles/brew/brew-mac.txt
    echo
elif uname -a | grep -q "Linux"; then
    echo "🐧 brew 安装 linux apps..."
    xargs brew install < ~/.dotfiles/brew/brew-linux.txt
    echo
fi

echo "✅ brew 安装结束"
echo