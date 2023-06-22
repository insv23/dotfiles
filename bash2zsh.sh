#!/usr/bin/env bash

apt update
apt install zsh -y
chsh -s /bin/zsh
echo $SHELL