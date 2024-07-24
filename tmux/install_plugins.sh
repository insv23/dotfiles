#!/bin/bash

# 子模块太他妈折磨人了, 再也不用了
# 在 .ignore 中添加 `tmux/plugins/` 将 tmux 插件全部不 track

# 安装 tpm 并删除其 .git 文件
git clone --depth=1 https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm


# 利用 tpm 的脚本安装插件
~/.tmux/plugins/tpm/bin/install_plugins
