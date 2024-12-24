# Added by Windsurf
export PATH="/Users/tony/.codeium/windsurf/bin:$PATH"

# ---- auto proxy ----
pxyon > /dev/null

# ---- direnv -----
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""     # 关闭 direnv 加载信息，使其不出现在终端中