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


# ---- bun -----

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun completions
[ -s "/Users/tony/.bun/_bun" ] && source "/Users/tony/.bun/_bun"



