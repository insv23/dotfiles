#!/bin/bash

if command -v bat &> /dev/null; then
  echo "bat 已安装"
else
  echo "bat 未安装"
  if uname -a | grep -q "Ubuntu"; then 
    sudo apt update
    sudo apt install bat -y
  
  elif uname -a | grep -q "Darwin"; then
    brew install bat
  fi
fi
