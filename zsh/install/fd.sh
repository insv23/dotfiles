#!/bin/bash

if command -v fd &> /dev/null; then
  echo "fd 已安装"
else
  echo "fd 未安装"
  if uname -a | grep -q "Ubuntu"; then 
    sudo apt update
    sudo apt install fd-find -y
  
  elif uname -a | grep -q "Darwin"; then
    brew install fd
  fi
fi
