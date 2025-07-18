# ---- auto proxy ----
# pxyon > /dev/null

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

# ===== Claude Code =====
alias cc="claude"
alias ccd="claude --dangerously-skip-permissions"
alias cc-upgrade="npm i -g @anthropic-ai/claude-code"
alias ccdo="claude --dangerously-skip-permissions --model opus"

# ===== kiro =====
# 这个是 kiro 的 shell 集成，用于在 kiro 中使用 zsh
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
# kiro end