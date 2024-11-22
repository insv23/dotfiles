#!/bin/zsh

# 检测是否需要自动开启代理
# 如果用户目录下存在 .walled 文件，则新终端自动开启代理
# 一个替代方案: 在各设备的 .local.zshrc 中直接使用 pxyon 命令
if [ -e ~/.walled ]
then
   pxyon
fi
