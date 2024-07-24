#!/bin/bash

if command -v eza &> /dev/null; then
  echo "eza 已安装"
else
  echo "eza 未安装"
  if uname -a | grep -q "Ubuntu"; then 
    sudo apt update
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
  
  elif uname -a | grep -q "Darwin"; then
    brew install eza
  fi
fi