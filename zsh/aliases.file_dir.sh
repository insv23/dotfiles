# cd folder
alias ..='cd ..'
alias ...='cd ../..'

# 交互模式 -i 可以防止在复制过程中意外覆盖文件。
alias cp='cp -i'
alias mv='mv -i'

# 列出当前目录下的所有文件和文件夹，并按照大小从大到小排序显示。
alias dsize='du -sh * | sort -hr'

# ---- Eza (better ls) -----
alias ll='eza \
  --header \
  --long \
  --all \
  --binary \
  --group \
  --icons=always \
  --git'

# 显示目录大小
alias lls='eza \
  --header \
  --long \
  --all \
  --binary \
  --group \
  --icons=always \
  --total-size \
  --git'

# 利用 eza 定义一个 tree 命令
# 不带任何数字, `tree` 默认展开 2 层
# 可以自己加数字表示展开层级, `tree 1/3/...`
tree() {
  depth=2
  if [ $# -gt 0 ]; then
    case "$1" in
    *[!0-9]*)
      echo "Invalid argument: '$1'. Please provide a numeric depth value." >&2
      return 1
      ;;
    *)
      depth="$1"
      ;;
    esac
  fi
  lss -T -L="$depth"
}

# Create a directory and cd into it
mkcd() {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -d $1 ]; then
    echo "'$1' already exists"
  else
    mkdir -pv $1 && cd $1
  fi
}

# Create a directory and copy directory name
mc() {
    mkdir "$1" && echo "$1" | pbcopy
}

# 下载的 Youtube 文件名有空格和其它字符，去掉这些字符, 只保留字母数字
# 例如: 'This Neovim ＂Plugin＂ Replaces 40 Others [qyB-sAvW2lI].mp4'
# 变为 'ThisNeovimPluginReplaces40Others.mp4'
# ds : delete space
alias ds='rename "s/\[.*?\]//g; s/[^A-Za-z0-9.]+//g"'

# 复制文件名到剪贴板，不要扩展名
# cn: copy name
cn() {
  local filename=$(basename "$1")
  [[ "$filename" =~ \. ]] && echo "$filename" | sed "s/\.[^.]*$//" | pbcopy || echo "$filename" | pbcopy
}

complete -f -o bashdefault cn

# 上面两个组合使用
# 1. macmini 上下载视频(mp4)和封面图到 downloads 目录下
# 2. 然后使用 ds *.mp4 将 mp4 的名字修整
# 3. 然后使用 cn *.mp4 将休整后的 mp4 的名字复制到剪贴板
# 4. 使用 mk 序号.刚刚复制的名字 执行翻译工作流
