# zsh-abbr 自定义配置
#
# 缩写定义文件在 ~/.dotfiles/zsh/abbreviations。
# zshrc 通过 ABBR_USER_ABBREVIATIONS_FILE 指向这个文件，zsh-abbr 启动时会读取它。
#
# 使用方式：
#   - 输入缩写后按空格展开，例如输入 pinga 后按空格，会展开成 ping 223.5.5.5
#   - 添加缩写用：abbr add 名称='完整命令'
#   - 查看缩写用：abbr list
#
# 这里把 zsh-abbr 的普通用户缩写镜像成 alias。
# 这样 zsh-syntax-highlighting 会把缩写识别为合法命令，completion/fzf-tab 也能搜索到这些缩写。
_zsh_abbr_mirror_to_aliases() {
  emulate -L zsh
  local key name expansion

  for key in ${(k)ABBR_REGULAR_USER_ABBREVIATIONS}; do
    name=${(Q)key}
    expansion=${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$key]}
    alias -- "$name=$expansion"
  done
}

_zsh_abbr_mirror_to_aliases
