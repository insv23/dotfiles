down() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.down.cli
  cd "$oldpwd"
}

burn() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.burn.cli
  cd "$oldpwd"
}

tran() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.translation.cli
  cd "$oldpwd"
}

whis() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.whisper.cli
  cd "$oldpwd"
}

noad() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.edit.noad
  cd "$oldpwd"
}

clip() {
  local oldpwd=$PWD
  cd ~/code/Python/bilingual_subtitle_machine
  uv run -m src.edit.clip
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
