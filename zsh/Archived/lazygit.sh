#!/bin/bash

if command -v lazygit &>/dev/null; then
	echo "lazygit 已安装"
else
	echo "lazygit 未安装"
	if uname -a | grep -q "Ubuntu"; then
		LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
		curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
		tar xf lazygit.tar.gz lazygit
		sudo install lazygit /usr/local/bin
		rm lazygit.tar.gz lazygit

	elif uname -a | grep -q "Darwin"; then
		brew install jesseduffield/lazygit/lazygit
		brew install lazygit
	fi
fi
