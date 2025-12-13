#!/usr/bin/env python3
import os
import subprocess
import sys


def parse_time(t):
    """把时间字符串转成秒数，支持 HH:MM:SS 或 MM:SS 或纯秒数"""
    parts = t.split(":")
    if len(parts) == 3:
        return int(parts[0]) * 3600 + int(parts[1]) * 60 + float(parts[2])
    elif len(parts) == 2:
        return int(parts[0]) * 60 + float(parts[1])
    else:
        return float(t)


def format_time(seconds):
    """秒数转回 HH:MM:SS.xxx 格式"""
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = seconds % 60
    return f"{h:02d}:{m:02d}:{s:06.3f}"


def get_duration(input_file):
    """用 ffprobe 获取视频时长"""
    cmd = [
        "ffprobe", "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        input_file
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return float(result.stdout.strip())


def invert_ranges(delete_ranges, total_duration):
    """把删除区间转换成保留区间"""
    # 按开始时间排序
    delete_ranges.sort(key=lambda x: x[0])

    keep_ranges = []
    current = 0.0

    for start, end in delete_ranges:
        if start > current:
            keep_ranges.append((current, start))
        current = max(current, end)

    # 最后一段
    if current < total_duration:
        keep_ranges.append((current, total_duration))

    return keep_ranges


def main():
    if len(sys.argv) < 3:
        print("Usage: noad <video_file> <start-end> [start-end ...]")
        print("Example: noad video.mp4 00:01:00-00:02:00 00:05:00-00:06:00")
        print("This will DELETE the specified segments (e.g., ads)")
        sys.exit(1)

    input_file = sys.argv[1]
    if not os.path.exists(input_file):
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)

    # 解析要删除的时间段
    delete_ranges = []
    for tr in sys.argv[2:]:
        try:
            start_str, end_str = tr.split("-", 1)
            start = parse_time(start_str)
            end = parse_time(end_str)
            delete_ranges.append((start, end))
        except ValueError:
            print(f"Error: Invalid time format '{tr}'. Use start-end (e.g., 00:01:00-00:02:00)")
            sys.exit(1)

    # 获取视频总时长
    print("Getting video duration...")
    total_duration = get_duration(input_file)
    print(f"Total duration: {format_time(total_duration)}")

    # 转换成保留区间
    keep_ranges = invert_ranges(delete_ranges, total_duration)

    if not keep_ranges:
        print("Error: Nothing left after removing all segments!")
        sys.exit(1)

    print(f"Deleting {len(delete_ranges)} segment(s), keeping {len(keep_ranges)} segment(s)")

    # 生成输出文件名
    filename, ext = os.path.splitext(input_file)
    output_file = f"{filename}_noad{ext}"

    # 构建 filter_complex
    filter_parts = []
    concat_inputs = []

    for i, (start, end) in enumerate(keep_ranges):
        filter_parts.append(
            f"[0:v]trim=start={start}:end={end},setpts=PTS-STARTPTS[v{i}]"
        )
        filter_parts.append(
            f"[0:a]atrim=start={start}:end={end},asetpts=PTS-STARTPTS[a{i}]"
        )
        concat_inputs.append(f"[v{i}][a{i}]")

    filter_str = ";".join(filter_parts)
    concat_str = "".join(concat_inputs) + f"concat=n={len(keep_ranges)}:v=1:a=1[outv][outa]"
    full_filter = f"{filter_str};{concat_str}"

    cmd = [
        "ffmpeg", "-i", input_file,
        "-filter_complex", full_filter,
        "-map", "[outv]",
        "-map", "[outa]",
        "-y",
        output_file,
    ]

    print(f"Output: {output_file}")
    print("Processing...")

    try:
        subprocess.run(cmd, check=True)
        print(f"\nDone! Saved to {output_file}")
    except subprocess.CalledProcessError:
        print("\nFFmpeg error occurred.")
        sys.exit(1)


if __name__ == "__main__":
    main()
