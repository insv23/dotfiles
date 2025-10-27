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
        # Remove existing directory in destination if it exists
        local dirname=$(basename "$dir")
        if [[ -d "$dest/$dirname" ]]; then
          echo "Removing existing directory: $dest/$dirname"
          rm -rf "$dest/$dirname"
        fi
        mv "$dir" "$dest"/
      else
        printf 'skip (no final_*.mp4): %s\n' "$dir"
      fi
    done
}

lsb() {
  local target_dir="~/Documents/biliV5"

  # Expand the tilde to full path
  target_dir="${target_dir/#\~/$HOME}"

  if [[ ! -d "$target_dir" ]]; then
    echo "Error: $target_dir does not exist or is not accessible"
    return 1
  fi

  echo "Directory structure of $target_dir:"
  echo

  # Use eza with tree format, showing only directories and limiting depth
  if command -v eza &> /dev/null; then
    eza --tree --level=3 --group-directories-first "$target_dir"
  else
    echo "Error: eza is not installed. Please install eza first."
    echo "You can install it with: brew install eza"
    return 1
  fi
}
