# ffmpeg_cut_middle: 剪切视频中间部分并无损拼接
# 用法: ffmpeg_cut_middle <输入文件> <删除开始时间> <删除结束时间> <输出文件>
# 示例: ffmpeg_cut_middle input.mp4 00:01:00 00:02:30 output.mp4
ffmpeg_cut_middle() {
    if [ "$#" -ne 4 ]; then
        echo "用法: ffmpeg_cut_middle <输入文件> <删除开始时间> <删除结束时间> <输出文件>"
        echo "示例: ffmpeg_cut_middle input.mp4 00:01:00 00:02:30 output.mp4"
        return 1
    fi

    local input_file="$1"
    local time_a="$2" # 删除的开始时间 (保留到此时间点)
    local time_b="$3" # 删除的结束时间 (从此时间点开始保留)
    local output_file="$4"

    # 生成唯一的临时文件名，防止冲突
    local timestamp=$(date +%s%N)
    local temp_part1="temp_part1_${timestamp}.mp4"
    local temp_part2="temp_part2_${timestamp}.mp4"
    local temp_list="temp_list_${timestamp}.txt"

    echo "正在剪切第一部分 (00:00:00 到 $time_a)..."
    ffmpeg -i "$input_file" -ss 00:00:00 -to "$time_a" -c copy "$temp_part1"
    if [ $? -ne 0 ]; then
        echo "错误: 剪切第一部分失败。"
        rm -f "$temp_part1" "$temp_part2" "$temp_list" # 清理可能残留的临时文件
        return 1
    fi

    echo "正在剪切第二部分 ($time_b 到结尾)..."
    ffmpeg -i "$input_file" -ss "$time_b" -c copy "$temp_part2"
    if [ $? -ne 0 ]; then
        echo "错误: 剪切第二部分失败。"
        rm -f "$temp_part1" "$temp_part2" "$temp_list"
        return 1
    fi

    echo "正在创建拼接列表文件: $temp_list..."
    echo "file '$temp_part1'" > "$temp_list"
    echo "file '$temp_part2'" >> "$temp_list"

    echo "正在无损拼接视频到 $output_file..."
    ffmpeg -f concat -safe 0 -i "$temp_list" -c copy "$output_file"
    if [ $? -ne 0 ]; then
        echo "错误: 拼接视频失败。"
        rm -f "$temp_part1" "$temp_part2" "$temp_list"
        return 1
    fi

    echo "正在清理临时文件..."
    rm -f "$temp_part1" "$temp_part2" "$temp_list"

    echo "完成! 输出文件已保存到 $output_file"
}
