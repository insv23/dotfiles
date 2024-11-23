# Hostname: C20240108106238

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# nvim
export PATH="$PATH:/opt/nvim-linux64/bin"

# ----- Homebrew(Linux) -----
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
