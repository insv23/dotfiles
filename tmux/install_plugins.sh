#!/bin/sh

# 在 .gitignore 中添加 `tmux/plugins/` 将 tmux 插件全部不 track
echo "🔄 安装 tmux 插件..."

mkdir -p ~/.tmux/plugins/

# 安装 tpm 并删除其 .git 文件
git clone --depth=1 https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm


# 利用 tpm 的脚本安装插件
~/.tmux/plugins/tpm/bin/install_plugins

echo " ✅ tmux 插件安装完成"
echo