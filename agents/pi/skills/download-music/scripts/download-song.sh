#!/usr/bin/env bash
set -euo pipefail

MUSIC_DIR="$HOME/Music/songs"
ARCHIVE_FILE="$MUSIC_DIR/.yt-dlp-download-archive.txt"
mkdir -p "$MUSIC_DIR"

fix_metadata() {
  local file="$1"
  local base stem artist title tmp

  if [[ ! -f "$file" ]]; then
    echo "Metadata skip, file not found: $file" >&2
    return 1
  fi

  base="$(basename "$file")"
  stem="${base%.*}"
  if [[ "$stem" != *" - "* ]]; then
    echo "Metadata skip, filename has no ' - ' separator: $base" >&2
    return 0
  fi

  artist="${stem%% - *}"
  title="${stem#* - }"
  artist="${artist#"${artist%%[![:space:]]*}"}"
  artist="${artist%"${artist##*[![:space:]]}"}"
  title="${title#"${title%%[![:space:]]*}"}"
  title="${title%"${title##*[![:space:]]}"}"

  if [[ -z "$artist" || -z "$title" ]]; then
    echo "Metadata skip, empty artist or title: $base" >&2
    return 0
  fi

  tmp="$(mktemp "$MUSIC_DIR/.${stem}.metadata.XXXXXX.mp3")"
  ffmpeg \
    -hide_banner \
    -loglevel error \
    -y \
    -i "$file" \
    -map 0 \
    -codec copy \
    -id3v2_version 3 \
    -metadata "artist=$artist" \
    -metadata "title=$title" \
    "$tmp"
  mv "$tmp" "$file"
  echo "Metadata updated: $base | artist=$artist | title=$title"
}

if [[ $# -eq 2 && "$1" == "--fix-metadata" ]]; then
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg is required but was not found in PATH." >&2
    exit 127
  fi
  fix_metadata "$2"
  exit $?
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <url>" >&2
  echo "       $0 --fix-metadata <mp3-file>" >&2
  exit 2
fi

URL="$1"

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "Error: yt-dlp is required but was not found in PATH." >&2
  exit 127
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Error: ffmpeg is required but was not found in PATH." >&2
  exit 127
fi

cd "$MUSIC_DIR"

before_file="$(mktemp)"
after_file="$(mktemp)"
trap 'rm -f "$before_file" "$after_file" "$before_file.info" "$after_file.info"' EXIT

find "$MUSIC_DIR" -maxdepth 1 -type f -name '*.mp3' -print > "$before_file"
find "$MUSIC_DIR" -maxdepth 1 -type f -name '*.info.json' -print > "$before_file.info"

# Download with source metadata preserved. The agent reads the .info.json after
# download and renames the MP3 semantically as "Artist - Title.mp3".
yt-dlp \
  --no-playlist \
  --extract-audio \
  --audio-format mp3 \
  --audio-quality 0 \
  --embed-metadata \
  --embed-thumbnail \
  --convert-thumbnails jpg \
  --write-info-json \
  --restrict-filenames \
  --windows-filenames \
  --download-archive "$ARCHIVE_FILE" \
  --paths "$MUSIC_DIR" \
  --output '%(uploader|Unknown Artist)s - %(title|Unknown Title)s.%(ext)s' \
  "$URL"

find "$MUSIC_DIR" -maxdepth 1 -type f -name '*.mp3' -print > "$after_file"
find "$MUSIC_DIR" -maxdepth 1 -type f -name '*.info.json' -print > "$after_file.info"

new_files="$(comm -13 <(sort "$before_file") <(sort "$after_file") || true)"
new_info_files="$(comm -13 <(sort "$before_file.info") <(sort "$after_file.info") || true)"

if [[ -n "$new_files" ]]; then
  echo "Downloaded:"
  echo "$new_files"
  echo "Metadata:"
  while IFS= read -r mp3_file; do
    [[ -n "$mp3_file" ]] && fix_metadata "$mp3_file"
  done <<< "$new_files"
  if [[ -n "$new_info_files" ]]; then
    echo "Info JSON:"
    echo "$new_info_files"
  fi
else
  echo "No new MP3 file detected. The URL may already be in the download archive or yt-dlp reused an existing file."
fi
