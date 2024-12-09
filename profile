# ~/.profile: executed by Bourne-compatble login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.

# 确保在使用 Bash 时加载 ~/.bashrc 文件，即使是在登录 shell 中。
# (登录 shell 默认不会自动加载 ~/.bashrc。)
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# 尝试禁用终端消息，同时确保即使操作失败也不会影响整个脚本或会话的执行。
mesg n 2> /dev/null || true

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
