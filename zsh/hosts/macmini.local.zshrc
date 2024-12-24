# Hostname: macmini

# ----- Cursor -----
# 在 crusor 中打开 command palette 搜索 `install cursor command`
alias cr='cursor'


# ---- Deno -----
            
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"


# ---- pnpm -----

export PNPM_HOME="/Users/tony/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# ---- direnv -----

eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""     # 关闭 direnv 加载信息，使其不出现在终端中


# ---- bun -----

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun completions
[ -s "/Users/tony/.bun/_bun" ] && source "/Users/tony/.bun/_bun"


# ---- auto proxy ----
pxyon > /dev/null


# envman(serviceman)
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# ---- cargo -----
export PATH="$HOME/.asdf/installs/rust/stable/bin:$PATH"


# ---- pipx ----
export PIPX_HOME=~/.pipx
