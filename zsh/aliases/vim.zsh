# Vim/vi 快捷工作流

# 在统一草稿目录中打开 vi；保存默认落在 ~/.vimdrafts，退出后保留原工作目录
vv() {
  mkdir -p "$HOME/.vimdrafts"
  (
    cd "$HOME/.vimdrafts" || exit
    vi "$@"
  )
}

vvls() {
  mkdir -p "$HOME/.vimdrafts"
  if alias ll >/dev/null 2>&1; then
    ll "$HOME/.vimdrafts"
  else
    ls -la "$HOME/.vimdrafts"
  fi
}
