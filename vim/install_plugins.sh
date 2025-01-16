#!/bin/sh

# 在 .gitignore 中添加 `vim/pack/vendor/start/` 将 vim 插件全部不 track

echo "🔄 安装 vim 插件..."

mkdir -p ~/.vim/pack/vendor/start/

git clone --depth=1 https://github.com/preservim/nerdtree.git ~/.vim/pack/vendor/start/nerdtree
git clone --depth=1 https://github.com/roxma/vim-tmux-clipboard.git ~/.vim/pack/vendor/start/vim-tmux-clipboard
git clone --depth=1 https://github.com/tmux-plugins/vim-tmux-focus-events.git ~/.vim/pack/vendor/start/vim-tmux-focus-events
git clone --depth=1 https://github.com/ojroques/vim-oscyank.git ~/.vim/pack/vendor/start/vim-oscyank

echo "✅ vim 插件安装完成"
echo