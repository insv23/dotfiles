# hostname: gpu

# ----- Homebrew(Linux) -----
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 忽略不安全的补全
# A 用户安装 homebrew 时会创建相关文件, B 用户无需再安装，只需直接使用 A 创建的就好
# 但会有警告, 使用此命令忽略警告
compinit -u

