#!/bin/sh

# ----- Homebrew -----
# 如果安装失败, 取消下面的注释, 换清华源
#export HOMEBREW_INSTALL_FROM_API=1
#export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
#export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
#export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
#export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"  # Linux
if [ "$(uname)" = "Darwin" ]; then            # macOS
    BREW_PATH="/opt/homebrew/bin/brew"
fi

if [ -x "$BREW_PATH" ] && "$BREW_PATH" --version >/dev/null 2>&1; then
    echo "✅ Homebrew is installed and working"
    echo
else
    echo "🚀 Homebrew is not installed or not working, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "🎉 Homebrew is installed successfully"
    echo
fi

# Linux brew 需要添加额外的路径指引(已经在 .local.zshrc 中完成, 此处只是说明)
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
