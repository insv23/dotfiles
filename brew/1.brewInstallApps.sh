#!/bin/bash

# ----- Brew Install Apps-----
echo "brew 安装 mac 与 Linux 均使用的 apps..."
xargs brew install < ~/.dotfiles/brew/brew-both.txt

if uname -a | grep -q "Darwin"; then
    echo "brew 安装 mac apps..."
    xargs brew install < ~/.dotfiles/brew/brew-mac.txt
elif uname -a | grep -q "Linux"; then
    echo "brew 安装 linux apps..."
    xargs brew install < ~/.dotfiles/brew/brew-linux.txt
fi

echo "brew 安装结束"
echo