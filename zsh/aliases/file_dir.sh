# 交互模式 -i 可以防止在复制过程中意外覆盖文件。
alias cp='cp -i'
alias mv='mv -i'

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

# mktc() - Make and Touch
# Creates a file at the specified path, automatically creating any necessary parent directories.
#
# Usage: mktc /path/to/your/file
#
# Parameters:
#   $1 - The full path to the file you want to create
#
# Examples:
#   mktc /home/user/projects/new_project/config/settings.json
#   (This will create all directories in the path if they don't exist, then create the empty file)
#
#   mktc ./projects/webapp/css/styles.css
#   (Works with relative paths too, creating the projects/webapp/css directories if needed)
mktc() { mkdir -p "$(dirname "$1")" && touch "$1" }



# Create a directory and copy directory name
mc() {
    mkdir "$1" && echo "$1" | pbcopy
}
