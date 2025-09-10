# Hostname: macmini
source ~/.dotfiles/zsh/hosts/macmini.local.secret.zshrc

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

# ===== pay-respects(theFuck 替代品) configuration =====
# 默认快捷键为 f
eval "$(pay-respects zsh --alias)"
# pay-respects end

# ===== llvm configuration =====
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# llvm end


alias down="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.download.cli"
alias info="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.download.ytdlp_extractor"
alias burn="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.embed.burning"
alias whis="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.transcribe.mlx_whisper_cli"
alias mvb="find ~/Documents/biliV5 -mindepth 1 -maxdepth 1 -type d -exec mv {} /Volumes/Fassssst/biliV5/ \;"