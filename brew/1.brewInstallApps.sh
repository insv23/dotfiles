#!/bin/sh

# 检查是否为 ARM Linux
if uname -a | grep -q "Linux" && uname -m | grep -q "aarch64"; then
    echo "⚠️ ARM Linux 暂不支持 Homebrew，退出安装..."
    exit 0
fi

# 安装单个包的函数
install_package() {
    echo "📦 正在安装: $1"
    if brew install "$1" 2>/dev/null; then
        echo "✅ 成功安装: $1"
    else
        echo "❌ 安装失败: $1"
        return 1
    fi
}

# 从文件读取并安装包的函数
install_from_file() {
    while read -r package || [ -n "$package" ]; do
        # 跳过空行和注释
        case "$package" in
            ""|\#*) continue ;;
            *) install_package "$package" || : ;;  # : 是 shell 的空操作符
        esac
    done < "$1"
}


# 根据系统添加 Homebrew 路径
if uname -a | grep -q "Darwin"; then
    # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "🍏 brew 安装 mac apps..."
    install_from_file ~/.dotfiles/brew/brew-mac.txt
else
    # Linux (x86_64)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "🐧 brew 安装 linux apps..."
    install_from_file ~/.dotfiles/brew/brew-linux.txt
fi

# 安装通用应用
echo "🍺 brew 安装通用 apps..."
install_from_file ~/.dotfiles/brew/brew-both.txt

echo "🎉 安装完成！"