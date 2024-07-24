#!/bin/bash

if command -v delta &> /dev/null; then
  echo "delta 已安装"
else
  echo "delta 未安装"
  if uname -a | grep -q "Ubuntu"; then 
    # 设置变量
    DELTA_VERSION="0.17.0"
    DEB_FILE="git-delta_${DELTA_VERSION}_amd64.deb"
    DOWNLOAD_URL="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${DEB_FILE}"

    # 更新包列表
    sudo apt update

    # 安装 wget（如果尚未安装）
    sudo apt install -y wget

    # 下载 deb 包
    echo "Downloading git-delta ${DELTA_VERSION}..."
    wget "$DOWNLOAD_URL"

    # 安装 deb 包
    echo "Installing git-delta..."
    sudo dpkg -i "$DEB_FILE"

    # 处理可能的依赖问题
    sudo apt install -f

    # 清理：删除下载的 deb 文件
    rm "$DEB_FILE"

    # 验证安装
    if command -v delta &> /dev/null
    then
        echo "git-delta ${DELTA_VERSION} has been successfully installed."
        delta --version
    else
        echo "Installation failed. Please check the error messages above."
    fi
  
  elif uname -a | grep -q "Darwin"; then
    brew install git-delta
  fi
fi
