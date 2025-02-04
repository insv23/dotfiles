# ----- Homebrew(Linux) -----
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# 忽略不安全的补全
# A 用户安装 homebrew 时会创建相关文件, B 用户无需再安装，只需直接使用 A 创建的就好
# 但会有警告, 使用此命令忽略警告
compinit -u

# export HF_ENDPOINT=https://hf-mirror.com # 不使用镜像，而是 pxy 后直接下载似乎也行
export MODEL_CACHE=/root/autodl-tmp/.cache/modelscope/hub/
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

alias pxy='source /etc/network_turbo'


# autodl 的机器的 hostname 是 autodl-container-cedc49a0d5-528adbab 这种很长的
# 无法自己改 hostname
# p10k 显示时替换主机名为 4090x8
typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@4090x8'
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@4090x8'
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@4090x8'

# For 'cargo install'
export PATH="$HOME/.asdf/installs/rust/stable/bin:$PATH"
