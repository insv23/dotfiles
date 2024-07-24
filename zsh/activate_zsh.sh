#!/bin/bash

# ----- bash to zsh -----
current_shell=$(which "$SHELL")

if echo "$current_shell" | grep -q "zsh"; then
	echo "Current shell is already zsh: $current_shell"
else
	echo "Current shell is not zsh. Attempting to switch to zsh..."

    sudo chsh -s "$(which zsh)" "$USER"

    echo "Current shell path is: $current_shell"