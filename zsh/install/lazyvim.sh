#!/bin/zsh

# Get current platform
if (($(uname | grep -c "Darwin") == 1)); then
	export current_platform="Mac"

elif [[ -f /etc/os-release ]]; then
	os=$(grep -E '^ID=' /etc/os-release | cut -d '=' -f2)

	if [[ "$os" == "ubuntu" ]]; then
		export current_platform="Ubuntu"

	else
		export current_platform="Other Linux"

	fi

else
	export current_platform="Other"

fi

# neovim
if command -v nvim &>/dev/null; then
	echo "Neovim is installed"
else
	echo "Neovim is not installed, installing..."

	if [["$current_platform" == "Mac"]]; then
		brew install neovim
		echo "Neovim is installed successfully"
	elif [["$current_platform" == "Ubuntu"]]; then
		sudo apt install neovim
		echo "Neovim is installed successfully"
	else
		echo "Install neovim manually: https://github.com/neovim/neovim/wiki/Installing-Neovim"
	fi
fi

# gnu-sed
if cmd -v sed &>/dev/null; then
	echo "sed is installed"
else
	echo "sed is not installed, installing..."

	if [["$current_platform" == "Mac"]]; then
		brew install gnu-sed
		echo "sed is installed successfully"
	else
		echo "The sed package comes pre-built alongside most Linux distributions."
		echo "If you don’t have it installed by default, install it manually: https://www.hostinger.com/tutorials/how-to-use-linux-sed-command-examples/#How_to_Install_the_sed_Command"
	fi
fi
