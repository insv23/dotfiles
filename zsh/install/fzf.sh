#!/bin/bash

if command -v fzf &> /dev/null; then
  echo "fzf 已安装"
else
  echo "fzf 未安装"
  if uname -a | grep -q "Ubuntu"; then
    sudo apt update
    sudo apt install fzf -y
  
  elif uname -a | grep -q "Darwin"; then
    brew install fzf
  fi
fi

if [ -f ~/.zsh/fzf-git.sh/fzf-git.sh ]; then
    echo "fzf-git.sh 已安装"
else
    echo "fzf-git.sh 未安装, 将安装..."
    git clone https://github.com/junegunn/fzf-git.sh.git ~/.zsh
fi