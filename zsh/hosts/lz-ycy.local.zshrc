# Hostname: C20240108106238

# ----- Homebrew(Linux) -----
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 通过 ssh 连接到该机器后，自动进入 tmux
if [[ -z "$TMUX" && -n "$SSH_CONNECTION" ]]; then
    tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi