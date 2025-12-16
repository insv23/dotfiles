# down() {
#   local oldpwd=$PWD
#   cd ~/code/Python/bilingual_subtitle_machine
#   uv run -m src.down.cli
#   cd "$oldpwd"
# }

# burn() {
#   local oldpwd=$PWD
#   cd ~/code/Python/bilingual_subtitle_machine
#   uv run -m src.burn.cli
#   cd "$oldpwd"
# }

# tran() {
#   local oldpwd=$PWD
#   cd ~/code/Python/bilingual_subtitle_machine
#   uv run -m src.translation.cli
#   cd "$oldpwd"
# }

# whis() {
#   local oldpwd=$PWD
#   cd ~/code/Python/bilingual_subtitle_machine
#   uv run -m src.whisper.cli
#   cd "$oldpwd"
# }

# noad() {
#   local oldpwd=$PWD
#   cd ~/code/Python/bilingual_subtitle_machine
#   uv run -m src.edit.noad
#   cd "$oldpwd"
# }

# clip() {
#   local oldpwd=$PWD
#   cd ~/code/Python/bilingual_subtitle_machine
#   uv run -m src.edit.clip
#   cd "$oldpwd"
# }

# mvb() {
#   local src=~/Documents/biliV5
#   local dest=/Volumes/Fassssst/biliV5

#   find "$src" -mindepth 1 -maxdepth 1 -type d -print0 |
#     while IFS= read -r -d '' dir; do
#       if [[ -n "$(find "$dir" -maxdepth 1 -type f -name 'final_*.mp4' -print -quit)" ]]; then
#         # Remove existing directory in destination if it exists
#         local dirname=$(basename "$dir")
#         if [[ -d "$dest/$dirname" ]]; then
#           echo "Removing existing directory: $dest/$dirname"
#           rm -rf "$dest/$dirname"
#         fi
#         mv "$dir" "$dest"/
#       else
#         printf 'skip (no final_*.mp4): %s\n' "$dir"
#       fi
#     done
# }

# lsb() {
#   local target_dir="~/Documents/biliV5"

#   # Expand the tilde to full path
#   target_dir="${target_dir/#\~/$HOME}"

#   if [[ ! -d "$target_dir" ]]; then
#     echo "Error: $target_dir does not exist or is not accessible"
#     return 1
#   fi

#   echo "Directory structure of $target_dir:"
#   echo

#   # Use eza with tree format, showing only directories and limiting depth
#   if command -v eza &> /dev/null; then
#     eza --tree --level=3 --group-directories-first "$target_dir"
#   else
#     echo "Error: eza is not installed. Please install eza first."
#     echo "You can install it with: brew install eza"
#     return 1
#   fi
# }

cleanbili() {
  local target_dir="/Volumes/Fassssst/biliV5"
  local size_limit="+5M"  # 5MB size limit
  local time_limit="1d"   # 1 days

  if [[ ! -d "$target_dir" ]]; then
    echo "Error: $target_dir does not exist or is not accessible"
    return 1
  fi

  echo "Scanning for files larger than 2MB in subdirectories older than 7 days..."
  echo

  # Get subdirectories that are older than 7 days
  local old_dirs=$(fd . "$target_dir" --min-depth 1 --max-depth 1 --type d --older "$time_limit")

  if [[ -z "$old_dirs" ]]; then
    echo "No subdirectories older than 7 days found."
    return 0
  fi

  echo "Found old subdirectories:"
  echo "$old_dirs" | while IFS= read -r dir; do
    local dir_age=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$dir")
    echo "  $dir (modified: $dir_age)"
  done
  echo

  # Find large files only in old directories
  local large_files=""
  while IFS= read -r dir; do
    local dir_files=$(fd . "$dir" --type f --size $size_limit)
    if [[ -n "$dir_files" ]]; then
      large_files+="${dir_files}\n"
    fi
  done <<< "$(echo "$old_dirs")"

  large_files=$(echo -e "$large_files" | grep -v '^$')

  if [[ -z "$large_files" ]]; then
    echo "No files larger than 2MB found in old subdirectories."
    return 0
  fi

  echo "Found the following large files in old subdirectories:"
  echo "$large_files" | while IFS= read -r file; do
    local size=$(du -h "$file" | cut -f1)
    echo "  $file ($size)"
  done

  echo
  echo -n "Do you want to delete these files? (y/N): "
  read -r response

  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Deleting large files..."
    echo "$large_files" | while IFS= read -r file; do
      if [[ -f "$file" ]]; then
        echo "Deleting: $file"
        rm -f "$file"
      fi
    done
    echo "Cleanup completed."
  else
    echo "Cleanup cancelled."
  fi
}
