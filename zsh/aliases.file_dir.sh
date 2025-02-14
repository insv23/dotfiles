# cd folder
alias ..='cd ..'
alias ...='cd ../..'

# 交互模式 -i 可以防止在复制过程中意外覆盖文件。
alias cp='cp -i'
alias mv='mv -i'

# 列出当前目录下的所有文件和文件夹，并按照大小从大到小排序显示。
alias dsize='du -sh * | sort -hr'

# ---- Eza (better ls) -----
if command -v eza >/dev/null 2>&1; then
  alias ls='eza \
    --header \
    --long \
    --all \
    --binary \
    --group \
    --icons=always \
    --git'

  # 显示目录大小
  alias lss='eza \
    --header \
    --long \
    --all \
    --binary \
    --group \
    --icons=always \
    --total-size \
    --git'

else
  alias ls='ls --color=auto'
  alias l='ls -l'
  alias ll='ls -lahF'
  alias lls='ls -lahFtr'
  alias la='ls -A'
  alias lc='ls -CF'
fi

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

# Create a directory, move files into it, rename mp4 file, copy directory name, rsync to server (only for bilibili folder)
mk() {
    mkdir "$1" && \
    mv /Users/tony/Downloads/* "$_" && \
    find "$_" -name "*.mp4" -exec mv {} "$_/1.mp4" \; && \
    rsync -avP "$1" 4090x8:~/bili/ && \
    echo "$1" | pbcopy
}