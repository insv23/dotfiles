# Hostname: macmini
source ~/.dotfiles/zsh/hosts/macmini.local.secret.zshrc

# 只在当前主机中使用的快捷别名

# ----- trash -----
export PATH="/opt/homebrew/opt/trash/bin:$PATH"
alias del='trash'

# ----- auto proxy -----
pxyon > /dev/null

# envman(serviceman)
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# ===== pnpm configuration =====
# 这个一般都是在本地机器上使用，应该都是 mac，所以统一使用 brew: https://pnpm.io/installation#using-homebrew
# 下面这个 Library 是在 mac 上才有的
# 安装后会自动在 zshrc 中添加下面配置，先手动删除，然后在 local.zshrc 中添加当前块
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ===== llvm configuration =====
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# llvm end

alias noad='uv run ~/.dotfiles/zsh/aliases/noad.py'
alias rm_media='~/.dotfiles/zsh/aliases/rm_media.py'
