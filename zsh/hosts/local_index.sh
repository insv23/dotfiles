#!/bin/sh

# 定义全局变量
DOTFILES_ZSH_HOSTS="$HOME/.dotfiles/zsh/hosts"

# 函数：创建主机配置文件
create_host_config() {
  hostname="$1"
  target_file="$DOTFILES_ZSH_HOSTS/${hostname}.local.zshrc"

  # 确保目标目录存在
  mkdir -p "$DOTFILES_ZSH_HOSTS"

  if [ ! -f "$target_file" ]; then
    echo "File $target_file does not exist. Creating..."

    uname_s=$(uname -s)
    uname_m=$(uname -m)
    if [ "$uname_s" = "Linux" ] && [ "$uname_m" = "x86_64" ]; then
      example_file="$DOTFILES_ZSH_HOSTS/linux_amd64.local.zshrc.example"
      if [ -f "$example_file" ]; then
        cp "$example_file" "$target_file"
        echo "Copied $example_file to $target_file"
      else
        echo "Example file $example_file not found. Creating an empty file."
        touch "$target_file"
      fi
    else
      touch "$target_file"
      echo "Created empty file: $target_file"
    fi
  fi
}

# 函数：加载主机配置文件
load_host_config() {
  hostname="$1"
  target_file="$DOTFILES_ZSH_HOSTS/${hostname}.local.zshrc"

  if [ -f "$target_file" ]; then
    . "$target_file"
  else
    echo "No specific configuration for this hostname. Please create a new one in $DOTFILES_ZSH_HOSTS/"
  fi
}

# 函数：处理特殊主机名
handle_special_hostname() {
  hostname="$1"

  case "$hostname" in
  "C20240108106238")
    . "$DOTFILES_ZSH_HOSTS/lz-ycy.local.zshrc"
    return 0 # 成功加载，返回 0
    ;;
  *)
  autodl-container-*)
    . "$DOTFILES_ZSH_HOSTS/autodl.local.zshrc"
    return 0 # 成功加载，返回 0
    ;;
  *)
    return 1 # 不是特殊主机名，返回 1
    ;;
  esac
}

main() {
  current_hostname=$(hostname)

  # 先处理特殊主机名(对应文件不为 hostname.local.zshrc 的)
  # 返回值 0 表示成功/真(和其他高级语言相反)
  handle_special_hostname "$current_hostname" && return

  # 处理默认主机名(对应文件为 hostname.local.zshrc 的)
  create_host_config "$current_hostname"
  load_host_config "$current_hostname"
}

# 执行主逻辑
main
