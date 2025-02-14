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


# ------------------ asdf 管理 ---------------------------
# ---- cargo 安装的包-----
export PATH="$HOME/.asdf/installs/rust/stable/bin:$PATH"

# ---- pnpm -----
# export PNPM_HOME="/Users/tony/Library/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac


# ---- bun -----
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"
# # bun completions
# [ -s "/Users/tony/.bun/_bun" ] && source "/Users/tony/.bun/_bun"

# ---- Deno -----
# 暂时还没装
# export DENO_INSTALL="$HOME/.deno"
# export PATH="$DENO_INSTALL/bin:$PATH"

# ------------------ asdf end ---------------------------



mk() {
    # 切换到 bilibili 目录，失败则报错退出
    cd ~/Documents/bilibili || { echo "Error: Could not change directory to ~/Documents/bilibili"; return 1; }
    # 创建一个以输入参数命名的文件夹
    mkdir "$1" && \
    # 将下载目录下的所有文件移动到新创建的文件夹中
    mv /Users/tony/Downloads/* "$_" && \
    # 查找新文件夹中的 mp4 文件，并将它们重命名为 1.mp4
    find "$_" -name "*.mp4" -exec mv {} "$_/1.mp4" \; && \
    # 如果使用 rsync 将该文件夹同步到远程服务器成功，则执行 then 部分
    if rsync -avP "$1" 4090x8:~/bili/; then
        # 使用 curl 发送包含文件夹名的成功消息到 ntfy 服务器
        curl -d "$1" "ntfy.sh/${NTFY_TOPIC}_bili_upload_succ"
    else
        # 使用 curl 发送包含错误信息的失败消息到 ntfy 服务器
        curl -d "Sync failed: $1" "ntfy.sh/${NTFY_TOPIC}_bili_upload_fail"
        # 返回错误代码1，表示脚本执行失败
        return 1
    fi
}