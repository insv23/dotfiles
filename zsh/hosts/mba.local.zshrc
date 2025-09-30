# 一些不该暴露到 key, 例如 ai api key
source ~/.dotfiles/zsh/hosts/mba.zshenv.secret

# ---- auto proxy ----
# pxyon > /dev/null

# ===== pnpm configuration =====
# 这个一般都是在本地机器上使用，应该都是 mac，所以统一使用 brew: https://pnpm.io/installation#using-homebrew
# 下面这个 Library 是在 mac 上才有的
# 安装后会自动在 zshrc 中添加下面配置，先手动删除，然后在 local.zshrc 中添加当前块
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ===== bun configuration =====
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# bun end

# # ===== Claude Code =====
# alias claude="/Users/tony/.claude/local/claude"
# alias cc="claude --dangerously-skip-permissions"
# alias ccc="claude --dangerously-skip-permissions --continue"
# alias cco="claude --dangerously-skip-permissions --model opus"

# # ===== xlaude =====
# alias xl="xlaude"
# alias xll="xlaude list"
# alias xlc="xlaude create"
# alias xld="xlaude delete"
# alias xln="xlaude new --with code"

alias down="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.download.cli"
alias info="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.download.ytdlp_extractor"
alias burn="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.embed.burning"
alias whis="cd ~/code/Python/bilingual_subtitle_machine && uv run -m src.transcribe.mlx_whisper_cli"

# glm4.5 接入 Claude Code
# Claude Code 使用 brew 安装, 因此使用 DISABLE_AUTOUPDATER=1 禁止自动更新
# GLM_API_TOKEN 放在 mba.zshenv.secret 
function ccglm() {
    ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic \
    ANTHROPIC_AUTH_TOKEN=$GLM_API_TOKEN \
    ANTHROPIC_MODEL=glm-4.5 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

# 以官方API 3折计费，支持缓存命中
# https://doc.302.ai/349734723e0
# claude-3-5-haiku-20241022
# claude-sonnet-4-20250514
# claude-opus-4-20250514
# 价格：原模型价格的3折
function cc302() {
    ANTHROPIC_BASE_URL=https://api.302.ai/cc \
    ANTHROPIC_AUTH_TOKEN=$CC_302_API_KEY \
    ANTHROPIC_MODEL=claude-sonnet-4-5-20250929 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

# carapace 名字自动补全: 内置了上百个常见 CLI 的补全（git、docker、kubectl、gh、ffmpeg、aws…）
# 可使用 `carapace --list` 查看可补全命令列表
# 配置样式: https://carapace-sh.github.io/carapace-bin/style.html
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# 查看应用程序的 Bundle ID，全称是 Bundle Identifier
id() {
  if [ -z "$1" ]; then
    echo "用法: id <应用名>"
    return 1
  fi
  osascript -e "id of app \"$1\""
}
