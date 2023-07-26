#!/bin/bash

if [ "$(uname)" == "Linux" ] && [ "$(lsb_release -si)" == "Ubuntu" ] && [ "$(basename $SHELL)" == "bash" ]
then
    apt update
    apt install zsh -y
    chsh -s /bin/zsh
    echo $SHELL
fi