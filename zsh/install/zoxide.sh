#!/bin/bash
if command -v zoxide &> /dev/null; then
  echo "zoxide 已安装"
else
  echo "zoxide 未安装，正在安装"
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
