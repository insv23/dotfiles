# MacBook Air 专属配置
# 一些不该暴露到 key, 例如 ai api key
source ~/.dotfiles/zsh/hosts/mba.zshenv.secret

# 只在当前主机中使用的快捷别名
source ~/.dotfiles/zsh/aliases/claude.zsh

# 查看应用程序的 Bundle ID，全称是 Bundle Identifier
id() {
  if [ -z "$1" ]; then
    echo "用法: id <应用名>"
    return 1
  fi
  osascript -e "id of app \"$1\""
}

# ---- auto proxy ----
# pxyon > /dev/null

# ===== pnpm configuration =====
# 这个一般都是在本地机器上使用，应该都是 mac，所以统一使用 brew: https://pnpm.io/installation#using-homebrew
# 下面这个 Library 是在 mac 上才有的
# 安装后会自动在 zshrc 中添加下面配置，先手动删除，然后在 local.zshrc 中添加当前块
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# ===== bun configuration =====
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# bun end


# ===== carapace 名字自动补全: 内置了上百个常见 CLI 的补全（git、docker、kubectl、gh、ffmpeg、aws…）
# 可使用 `carapace --list` 查看可补全命令列表
# 配置样式: https://carapace-sh.github.io/carapace-bin/style.html
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
if (( $+commands[carapace] )); then
  _carapace_cache="${XDG_CACHE_HOME:-$HOME/.cache}/carapace/init.zsh"
  if [[ ! -r "$_carapace_cache" || "$_carapace_cache" -ot "$commands[carapace]" ]]; then
    mkdir -p "${_carapace_cache:h}"
    carapace _carapace >| "$_carapace_cache" 2>/dev/null
  fi
  [[ -r "$_carapace_cache" ]] && source "$_carapace_cache"
  unset _carapace_cache
fi

# leetcode-cli
eval "$(leetcode completions)"
alias lcd="uv run --project ~/.leetcode -m lcd.cli --"

# 用 Rebased 打开文件或目录
# 社区有人将 Jetbrains 家 git 功能单独拆出来做的一个软件
# https://github.com/DetachHead/rebased
# 用法:
# rb .
# rb README.md
# rb --line 20 ~/.zshrc
rb() {
  /Applications/Rebased.app/Contents/MacOS/idea "$@"
}

