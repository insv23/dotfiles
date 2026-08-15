---
name: download-music
description: Music downloader for saving songs to ~/Music/songs. Download a single music/song/audio URL with yt-dlp, extract MP3 at best quality, embed metadata and thumbnail, and name the file as Artist - Title.mp3. Use when the user asks to download music, save a song, convert audio to MP3, or put audio into the songs folder.
---

# Download Music

Use this skill when the user provides a music/audio URL and wants it downloaded into `~/Music/songs` as an MP3 named like:

```text
Artist - Title.mp3
```

## Workflow

1. Require exactly one URL.
2. Run the helper script from the skill directory:

```bash
./scripts/download-song.sh '<url>'
```

3. Read the downloaded MP3 path and `.info.json` path from the script output.
4. Inspect the `.info.json` metadata fields such as `artist`, `track`, `title`, `uploader`, `channel`, and `webpage_url`.
5. Use AI judgment to choose a clean final filename in this exact format:

```text
Artist - Title.mp3
```

6. Rename the MP3 to the clean final filename in `~/Music/songs`.
7. After any rename, rewrite the MP3 metadata from the final filename:

```bash
./scripts/download-song.sh --fix-metadata '~/Music/songs/Artist - Title.mp3'
```

8. Report only the final downloaded file path.
9. If the metadata is too ambiguous to confidently identify the artist and title, ask for the intended `Artist - Title` name.

## Behavior

The script:

- downloads into `~/Music/songs`
- extracts audio as MP3 with `--audio-quality 0`
- avoids playlists with `--no-playlist`
- embeds metadata and thumbnails
- writes a `.info.json` metadata file for AI-assisted naming
- uses a safe temporary filename based on uploader and title
- sanitizes filenames through yt-dlp's restricted filename mode
- automatically rewrites MP3 `artist` and `title` metadata from the filename format `Artist - Title.mp3`

The agent:

- uses the downloaded file and `.info.json` metadata to infer the final song name
- removes platform/channel noise such as region suffixes, `Official Video`, `Official Music Video`, `Lyrics`, `MV`, and similar upload-title artifacts
- renames the file to `Artist - Title.mp3`
- runs `./scripts/download-song.sh --fix-metadata <final-mp3-path>` after renaming
- keeps the response concise and reports only the final path

## Usage

```bash
~/.pi/agent/skills/download-song/scripts/download-song.sh 'https://example.com/song-url'
```
