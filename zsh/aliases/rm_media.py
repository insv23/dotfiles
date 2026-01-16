#!/usr/bin/env python3
"""
删除指定目录下的所有视频和音频文件

在 ~/.dotfiles/zsh/aliases.sh 中添加以下别名以便全局使用:
    alias rm_media='~/.dotfiles/zsh/aliases/rm_media.py'

用法:
    rm_media <目录1> [目录2] [目录3] ...

示例:
    rm_media /Volumes/Fassssst/biliV5
    rm_media ~/Downloads /tmp/media
    rm_media .

警告: 此脚本会直接删除文件，无确认提示，请谨慎使用！
"""

import os
import sys
from pathlib import Path

# 支持的视频和音频扩展名
VIDEO_EXTENSIONS = {
    ".mp4",
    ".mkv",
    ".avi",
    ".mov",
    ".flv",
    ".wmv",
    ".webm",
    ".m4v",
    ".ts",
    ".vob",
    ".mpg",
    ".mpeg",
    ".3gp",
    ".f4v",
    ".rm",
    ".rmvb",
}

AUDIO_EXTENSIONS = {
    ".mp3",
    ".m4a",
    ".flac",
    ".wav",
    ".aac",
    ".ogg",
    ".wma",
    ".opus",
    ".ape",
    ".alac",
    ".dsd",
    ".dsf",
}

MEDIA_EXTENSIONS = VIDEO_EXTENSIONS | AUDIO_EXTENSIONS


def remove_media_files(directories):
    """删除指定目录中的所有媒体文件"""
    total_removed = 0
    total_size = 0
    errors = []

    for directory in directories:
        dir_path = Path(directory).expanduser().resolve()

        if not dir_path.exists():
            print(f"错误: 目录不存在: {directory}")
            continue

        if not dir_path.is_dir():
            print(f"错误: 不是目录: {directory}")
            continue

        print(f"\n处理目录: {dir_path}")
        removed_count = 0

        # 递归遍历所有文件
        for file_path in dir_path.rglob("*"):
            if file_path.is_file() and file_path.suffix.lower() in MEDIA_EXTENSIONS:
                try:
                    file_size = file_path.stat().st_size
                    file_path.unlink()
                    removed_count += 1
                    total_removed += 1
                    total_size += file_size
                    print(f"  已删除: {file_path}")
                except Exception as e:
                    error_msg = f"无法删除 {file_path}: {e}"
                    errors.append(error_msg)
                    print(f"  {error_msg}")

        print(f"目录 {dir_path} 删除了 {removed_count} 个文件")

    # 打印统计信息
    print(f"\n{'=' * 60}")
    print(f"总计删除: {total_removed} 个文件")
    print(f"释放空间: {format_size(total_size)}")

    if errors:
        print(f"\n遇到 {len(errors)} 个错误:")
        for error in errors:
            print(f"  - {error}")

    return total_removed


def format_size(bytes_size):
    """格式化文件大小"""
    for unit in ["B", "KB", "MB", "GB", "TB"]:
        if bytes_size < 1024.0:
            return f"{bytes_size:.2f} {unit}"
        bytes_size /= 1024.0
    return f"{bytes_size:.2f} PB"


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    directories = sys.argv[1:]
    remove_media_files(directories)


if __name__ == "__main__":
    main()
