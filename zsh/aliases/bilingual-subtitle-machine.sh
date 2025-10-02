down() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.down.cli
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
