#!/bin/bash

if basename $SHELL | grep -q "bash"; then
    echo "Current shell is bash, try to install and switch to zsh"

    if uname -a | grep -q "Ubuntu"; then
        apt update
        apt install zsh -y
        chsh -s /bin/zsh
        echo "Current shell is $SHELL"
    
    elif uname -a | grep -q "Darwin"; then
        echo "MacOS's default shell should be zsh, try to switch to /bin/zsh"
        chsh -s /bin/zsh

    else
        echo "Install zsh manually: https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH"
    fi

fi