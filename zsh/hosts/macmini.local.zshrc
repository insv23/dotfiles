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

# ===== llvm configuration =====
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# llvm end


down() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.download.cli
  cd "$oldpwd"
}

info() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.download.ytdlp_extractor
  cd "$oldpwd"
}

burn() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.embed.burning
  cd "$oldpwd"
}

tran() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.translate.cli
  cd "$oldpwd"
}

whis() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.transcribe.mlx_whisper_cli
  cd "$oldpwd"
}

noad() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.edit.cli
  cd "$oldpwd"
}

mvb() {
  local src=~/Documents/biliV5
  local dest=/Volumes/Fassssst/biliV5

  find "$src" -mindepth 1 -maxdepth 1 -type d -print0 |
    while IFS= read -r -d '' dir; do
      if [[ -n "$(find "$dir" -maxdepth 1 -type f -name 'final_*.mp4' -print -quit)" ]]; then
        mv "$dir" "$dest"/
      else
        printf 'skip (no final_*.mp4): %s\n' "$dir"
      fi
    done
}
