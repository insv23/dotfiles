#!/bin/sh

# 在 .gitignore 中添加 `tmux/plugins/` 将 tmux 插件全部不 track
echo "🔄 安装 tmux tpm..."

mkdir -p ~/.tmux/plugins/

# 安装 tpm 并删除其 .git 文件
git clone --depth=1 https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm


echo "✅ tmux tpm 安装完成"
echo "打开 tmux, 使用 `prefix shift i` 让 tpm 安装 tmux 插件"
echo