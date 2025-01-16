# ----- Homebrew(Linux) -----
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 通过 ssh 连接到该机器后，自动进入 tmux
if [[ -z "$TMUX" && -n "$SSH_CONNECTION" ]]; then
    tmux new-session -A -s ssh_tmux
fi

# 忽略不安全的补全
# A 用户安装 homebrew 时会创建相关文件, B 用户无需再安装，只需直接使用 A 创建的就好
# 但会有警告, 使用此命令忽略警告
compinit -u

export MODEL_CACHE=/root/autodl-tmp/.cache/modelscope/hub/
export HF_ENDPOINT=https://hf-mirror.com
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

alias pxy='source /etc/network_turbo'
