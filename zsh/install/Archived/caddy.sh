#!/bin/bash

if command -v caddy &> /dev/null; then
  echo "caddy 已安装"
else
  echo "caddy 未安装"
  if uname -a | grep -q "Ubuntu"; then 
    # Install caddy
    sudo apt update && sudo apt upgrade
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy -y 
  fi
fi
