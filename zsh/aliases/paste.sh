# 设置一个全局别名，能够将命令输出复制到系统剪贴板
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

# 将输出重定向到 https://paste.rs/ 中, 返回一个链接
alias -g P='| tee >(curl --data-binary @- https://paste.rs/)'