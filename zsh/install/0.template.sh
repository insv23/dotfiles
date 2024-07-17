#!/bin/bash

# GitHub 仓库信息(需要根据 release 页实际文件名手动构造文件名)
REPO="junegunn/fzf"
BINARY_NAME="fzf"
upgrade=false

# 获取最新版本号
get_latest_version() {
    curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
    # reutnr 'v0.54.0'
}

# 检测操作系统和架构
detect_os_and_arch() {
    local uname_output=$(uname -a)
    if [[ $uname_output == *"Linux"* ]]; then
        if [[ $uname_output == *"x86_64"* ]]; then
            echo "linux_x86_64"
        elif [[ $uname_output == *"aarch64"* || $uname_output == *"armv"* ]]; then
            echo "linux_arm"
        else
            echo "linux_unknown"
        fi
    elif [[ $uname_output == *"Darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# 安装或升级软件
install_or_upgrade() {
    local os_arch=$(detect_os_and_arch)
    local latest_version=$(get_latest_version)

    if [ "$os_arch" = "macos" ]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew 未安装，请先安装 Homebrew"
            exit 1
        fi
        
        if ! brew list $BINARY_NAME &> /dev/null; then
            echo "正在使用 Homebrew 安装 ${BINARY_NAME}..."
            brew install $BINARY_NAME
        elif $upgrade; then
            echo "正在使用 Homebrew 升级 ${BINARY_NAME}..."
            brew upgrade $BINARY_NAME
        fi
    else
        # 构造文件名(每个软件都不一样)
        # ${latest_version#v} '#v'表示删除版本号开头的 "v" 字符（如果存在的话）
        local filename="${BINARY_NAME}-${latest_version#v}-"
        case $os_arch in
            linux_arm)
                filename+="linux_arm64"
                ;;
            linux_x86_64)
                filename+="linux_amd64"
                ;;
            *)
                echo "不支持的系统架构: $os_arch"
                exit 1
                ;;
        esac
        filename+=".tar.gz"

        local download_url="https://github.com/${REPO}/releases/download/${latest_version}/${filename}"

        # 创建临时目录
        local temp_dir=$(mktemp -d)
        
        # 下载并解压文件
        curl -L "$download_url" | tar -xz -C "$temp_dir"

        # 设置执行权限
        chmod +x "$temp_dir/$BINARY_NAME"
        
        # 移动二进制文件到 /usr/local/bin
        sudo mv "$temp_dir/$BINARY_NAME" "/usr/local/bin/$BINARY_NAME"
        
        # 清理临时目录
        rm -rf "$temp_dir"
    fi

    echo "${BINARY_NAME} 操作完成，版本为 ${latest_version}"
}

# 主函数
main() {
    local os_arch=$(detect-system)

    if ! command -v $BINARY_NAME &> /dev/null; then
        echo "${BINARY_NAME} 未安装，正在安装..."
        install_or_upgrade
    else
        echo "${BINARY_NAME} 已安装"
        
        local current_version=$($BINARY_NAME --version | cut -d ' ' -f 1)
        local latest_version=$(get_latest_version)
        
        if [ "$current_version" != "$latest_version" ]; then
            echo "发现新版本: $latest_version"
            
            if $upgrade; then
                echo "正在升级 ${BINARY_NAME}..."
                install_or_upgrade
            else
                echo "如需升级，请将 upgrade 变量设置为 true"
            fi
        else
            echo "${BINARY_NAME} 已是最新版本"
        fi
    fi
}

# 执行主函数
main
