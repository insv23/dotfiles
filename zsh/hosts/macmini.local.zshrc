# Hostname: macmini

# ----- Cursor -----
# 在 crusor 中打开 command palette 搜索 `install cursor command`
alias cr='cursor'

# ----- trash -----
export PATH="/opt/homebrew/opt/trash/bin:$PATH"
alias del='trash'

# ----- auto proxy -----
pxyon > /dev/null

# envman(serviceman)
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

