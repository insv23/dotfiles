########### 别名 C - 复制到剪贴板 ###########
# 用法示例:
# # 复制当前路径到剪贴板
# pwd C
# 
# # 复制文件内容到剪贴板
# cat ~/.zshrc C
# 
# # 复制 ls 输出到剪贴板
# ls -la C
# 
# # 复制 git diff 到剪贴板
# git diff C
############
# alias -g 全局别名，能出现在命令的任何位置；普通别名只能在开头
# zsh 大小写敏感
# mac 上走 pbcopy，X11 Linux 用 xclip，Wayland 就用 wl-copy。
if command -v pbcopy >/dev/null 2>&1; then
  alias -g C='| tee >(pbcopy)'
elif command -v xclip >/dev/null 2>&1; then
  alias -g C='| tee >(xclip -selection clipboard)'
elif command -v wl-copy >/dev/null 2>&1; then
  alias -g C='| tee >(wl-copy)'
else
  unalias C 2>/dev/null
fi

########### 别名 P - 上传到 paste.rs ###########
# 用法示例:
# # 粘贴当前路径到剪贴板
# pwd P
# 
# # 粘贴文件内容到剪贴板
# cat ~/.zshrc P
# 
# # 粘贴 ls 输出到剪贴板
# ls -la P
# 
# # 粘贴 git diff 到剪贴板
# git diff P
############
# 将输出重定向到 https://paste.rs/ 中, 返回一个链接
# 如果 curl 返回的 URL 末尾没有 \n 换行符，zsh 会用反色的 % 来标记这种"不完整行"，因此在 curl 后面加个 echo 输出换行符
alias -g P='| tee >(curl --data-binary @- https://paste.rs/; echo)'

# 例如远程服务器无法直接访问本地剪贴板，即 cmd/ctrl v 失效，就可以:
# 1. 先在本地编辑好文件，然后 cat file P 上传到 paste.rs，获取到链接
# 2. 在远程服务器上，使用 curl 下载文件
#    curl 链接 > file.txt
