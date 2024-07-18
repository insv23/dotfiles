#!/bin/bash

# ----- bash to zsh -----
current_shell=$(which "$SHELL")

if echo "$current_shell" | grep -q "zsh"; then
	echo "Current shell is already zsh: $current_shell"
else
	echo "Current shell is not zsh. Attempting to install and switch to zsh..."

	if echo "$current_shell" | grep -q "bash"; then
		if uname -a | grep -q "Ubuntu"; then
			sudo apt update
			sudo apt install zsh -y
			sudo chsh -s "$(which zsh)" "$USER"
			echo "Installed zsh. Please log out and log back in for changes to take effect."

		elif uname -a | grep -q "Darwin"; then
			echo "MacOS detected. Attempting to switch to zsh"
			sudo chsh -s "$(which zsh)" "$USER"
			echo "Please log out and log back in for changes to take effect."

		else
			echo "Unsupported system. Please install zsh manually: https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH"
		fi
	else
		echo "Current shell is neither zsh nor bash. Please install zsh manually: https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH"
	fi
fi

echo "Current shell path is: $current_shell"

# ----- Homebrew -----
# 如果安装失败, 取消下面的注释, 换清华源
#export HOMEBREW_INSTALL_FROM_API=1
#export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
#export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
#export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
#export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

if command -v brew &>/dev/null; then
    echo "Homebrew is installed"
else
    echo "Homebrew is not installed, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew is installed successfully"
fi

# Linux brew 需要添加额外的路径指引(已经在 .local.zshrc 中完成, 此处只是说明)
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# ----- Unzip -----
# if command -v unzip &>/dev/null; then
# 	echo "unzip 已安装"
# else
# 	echo "unzip 未安装"
# 	if uname -a | grep -q "Ubuntu"; then
# 		sudo apt update
# 		sudo apt install -y unzip
# 	fi
# fi
