# ---- auto proxy ----
pxyon > /dev/null

# ===== pnpm configuration =====
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ===== bun configuration =====
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# bun end

# ===== pay-respects(theFuck 替代品) configuration =====
# 默认快捷键为 f
eval "$(pay-respects zsh --alias)"
# pay-respects end
