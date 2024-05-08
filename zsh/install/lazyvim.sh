#!/bin/zsh

###### Get current platform
# if uname -a | grep -q "Darwin"; then
# 	export current_platform="Mac"

# elif uname -a | grep -q "Ubuntu"; then
# 	export current_platform="Ubuntu"

# else
# 	export current_platform="Other"
# fi


# neovim
if command -v nvim &>/dev/null; then
	echo "Neovim is installed"
else
	echo "Neovim is not installed, installing..."

	# if [["$current_platform" == "Mac"]]; then // Not works: https://blog.insv.xyz/shell-str-compare
	if uname -a | grep -q "Darwin"; then
		brew install neovim
		echo "Neovim is installed successfully"

	elif uname -a | grep -q "Ubuntu"; then
		sudo apt install neovim -y
		echo "Neovim is installed successfully"

	else
		echo "Install neovim manually: https://github.com/neovim/neovim/wiki/Installing-Neovim"
	fi
fi

# gnu-sed
if command -v sed &>/dev/null; then
	echo "sed is installed"
else
	echo "sed is not installed, installing..."

	if uname -a | grep -q "Darwin"; then
		brew install gnu-sed
		echo "sed is installed successfully"
	else
		echo "The sed package comes pre-built alongside most Linux distributions."
		echo "If you don’t have it installed by default, install it manually: https://www.hostinger.com/tutorials/how-to-use-linux-sed-command-examples/#How_to_Install_the_sed_Command"
	fi
fi
