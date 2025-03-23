# Hostname: macmini

# ----- Cursor -----
# 在 crusor 中打开 command palette 搜索 `install cursor command`
alias cr='cursor'

# ----- trash -----
export PATH="/opt/homebrew/opt/trash/bin:$PATH"
alias del='trash'

# ----- auto proxy -----
pxyon > /dev/null

# envman(serviceman)
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


mk() {
    # 检查下载目录是否存在 mp4 文件
    mp4_file=$(find ~/Downloads -maxdepth 1 -name "*.mp4" -print -quit)
    if [ -z "$mp4_file" ]; then
        echo "Error: No mp4 files found in ~/Downloads"
        return 1
    fi
    
    # 切换到 bilibili 目录
    cd ~/Documents/bilibili || { echo "Error: Could not change directory to ~/Documents/bilibili"; return 1; }
    
    # 创建目标目录(如果不存在)
    mkdir -p "$1"
    
    # 获取原文件名并显示移动信息
    original_name=$(basename "$mp4_file")
    echo "Moving '$original_name' to '$1/1.mp4'"
    
    # 移动所有文件，并特别处理 mp4 文件
    mv ~/Downloads/* "$1/" && \
    mv "$1"/*.mp4 "$1/1.mp4" || { echo "Error: Failed to move files"; return 1; }
    
    # 尝试同步到远程服务器
    if rsync -avP "$1" 4090x8:~/bili/; then
        curl -d "$1" "ntfy.sh/${NTFY_TOPIC}_bili_upload_succ"
    else
        curl -d "Sync failed: $1" "ntfy.sh/${NTFY_TOPIC}_bili_upload_fail"
        return 1
    fi
    
    # 返回下载目录
    cd ~/Downloads || { echo "Error: Could not change directory to ~/Downloads"; return 1; }
}