#!/bin/bash
if command -v pyenv &> /dev/null; then
  echo "pyenv 已安装"
else
  echo "pyenv 未安装，正在安装"
  curl https://pyenv.run | bash
fi
