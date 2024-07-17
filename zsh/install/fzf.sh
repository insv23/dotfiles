#!/bin/bash

if command -v fzf &> /dev/null; then
  echo "fzf 已安装"
else
  echo "fzf 未安装"
  if uname -a | grep -q "Ubuntu"; then
    # 设置变量
    FZF_VERSION="0.54.0"
    DOWNLOAD_URL="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
    INSTALL_DIR="/usr/local/bin"

    # 创建临时目录
    TMP_DIR=$(mktemp -d)

    # 下载 fzf
    echo "Downloading fzf v${FZF_VERSION}..."
    wget -q "${DOWNLOAD_URL}" -O "${TMP_DIR}/fzf.tar.gz"

    # 解压
    echo "Extracting..."
    tar -xzf "${TMP_DIR}/fzf.tar.gz" -C "${TMP_DIR}"

    # 安装
    echo "Installing fzf to ${INSTALL_DIR}..."
    sudo mv "${TMP_DIR}/fzf" "${INSTALL_DIR}"

    # 设置执行权限
    sudo chmod +x "${INSTALL_DIR}/fzf"

    # 清理临时文件
    rm -rf "${TMP_DIR}"

    echo "fzf v${FZF_VERSION} has been successfully installed to ${INSTALL_DIR}/fzf"

    # 验证安装
    fzf --version

    echo "Installation complete!"
  
  elif uname -a | grep -q "Darwin"; then
    brew install fzf
  fi
fi

if [ -f ~/.zsh/fzf-git.sh/fzf-git.sh ]; then
    echo "fzf-git.sh 已安装"
else
    echo "fzf-git.sh 未安装, 将安装..."
    cd ~/.zsh
    git clone https://github.com/junegunn/fzf-git.sh.git 
fi