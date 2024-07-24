#!/bin/bash

# ----- Homebrew -----
# 如果安装失败, 取消下面的注释, 换清华源
#export HOMEBREW_INSTALL_FROM_API=1
#export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
#export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
#export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
#export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

if command -v brew &>/dev/null; then
    echo "\n\nHomebrew is installed\n\n"
else
    echo "Homebrew is not installed, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew is installed successfully\n\n"
fi

# Linux brew 需要添加额外的路径指引(已经在 .local.zshrc 中完成, 此处只是说明)
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
