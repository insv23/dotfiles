#!/bin/bash
if command -v atuin &> /dev/null; then
  echo "atuin 已安装"
else
  echo "atuin 未安装，正在安装"
  bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
fi
