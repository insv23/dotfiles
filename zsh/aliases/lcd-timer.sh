#!/bin/bash
# lcd-timer.sh - LeetCode Daily 计时器
# Usage: lcd-timer.sh <start_timestamp> <duration_file> [initial_elapsed]

start_ts=$1
duration_file=$2
initial_elapsed=${3:-0}

# 将起始时间回拨，使计时从 initial_elapsed 开始
start_ts=$((start_ts - initial_elapsed))

paused=0
pause_total=0
pause_start=0
elapsed=0

# 保存终端状态
saved_tty=$(stty -g 2>/dev/null)
cleanup() {
    stty "$saved_tty" 2>/dev/null
    tput cnorm 2>/dev/null
}
trap cleanup EXIT INT TERM

stty -echo 2>/dev/null
tput civis 2>/dev/null

while true; do
    now=$(date +%s)
    if [[ $paused -eq 0 ]]; then
        elapsed=$((now - start_ts - pause_total))
    fi

    mins=$((elapsed / 60))
    secs=$((elapsed % 60))

    # 每秒写入当前耗时，供 vim wrapper 读取
    echo "$elapsed" > "$duration_file"

    if [[ $paused -eq 0 ]]; then
        printf "\r  ⏱  %02d:%02d  │  [p]暂停  [q]结束 " $mins $secs
    else
        printf "\r  ⏸  %02d:%02d  │  [r]继续  [q]结束 " $mins $secs
    fi

    read -rsn1 -t1 key 2>/dev/null

    case "$key" in
        p|P)
            if [[ $paused -eq 0 ]]; then
                paused=1
                pause_start=$(date +%s)
            fi
            ;;
        r|R)
            if [[ $paused -eq 1 ]]; then
                paused=0
                pause_total=$((pause_total + $(date +%s) - pause_start))
            fi
            ;;
        q|Q)
            echo "$elapsed" > "$duration_file"
            printf "\n  ⏹  计时结束: %d分%02d秒\n" $mins $secs
            exit 0
            ;;
    esac
done
