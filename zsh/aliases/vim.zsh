# Vim/vi 快捷工作流

# 进入统一草稿目录并打开 vi；用 :new 创建 buffer，保存时文件会落在 ~/.vimdrafts
vv() {
  mkdir -p "$HOME/.vimdrafts"
  cd "$HOME/.vimdrafts" || return
  vi "$@"
}

vvls() {
  mkdir -p "$HOME/.vimdrafts"
  if alias ll >/dev/null 2>&1; then
    ll "$HOME/.vimdrafts"
  else
    ls -la "$HOME/.vimdrafts"
  fi
}
