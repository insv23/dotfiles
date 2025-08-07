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

# ===== Claude Code =====
alias claude="/Users/tony/.claude/local/claude"
alias cc="claude --dangerously-skip-permissions"
alias ccc="claude --dangerously-skip-permissions --continue"
alias cco="claude --dangerously-skip-permissions --model opus"
alias cc-upgrade="npm i -g @anthropic-ai/claude-code"

# ===== xlaude =====
alias xl="xlaude"
alias xll="xlaude list"
alias xlc="xlaude create"
alias xld="xlaude delete"
alias xln="xlaude new --with code"

# ===== tmuxai =====
alias ti="tmuxai"