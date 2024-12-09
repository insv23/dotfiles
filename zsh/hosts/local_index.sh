# ----- 根据主机名选择相应的配置文件 -----

# 获取当前主机名
current_hostname=$(hostname)

case "$current_hostname" in
  "macmini")
    source ~/.zsh/hosts/macmini.local.zshrc
    ;;
  "mba")
    source ~/.zsh/hosts/mba.local.zshrc
    ;;
  "babel")
    source ~/.zsh/hosts/babel.local.zshrc
    ;;
  "C20240108106238")
    source ~/.zsh/hosts/lz-ycy.local.zshrc
    ;;
  *)
    # 默认配置，如果没有匹配的主机名
    echo "No specific configuration for this hostname. Please create a new one in ~/.dotfiles/zsh/hosts/"
    ;;
esac