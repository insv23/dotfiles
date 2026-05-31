# NVM 配置：初始化 Node 版本管理器，目录切换时自动识别 .nvmrc
# ========================================
# NVM (Node Version Manager) 配置
# ========================================
#
# 推荐使用 NVM 管理 Node.js 版本，而非 Homebrew。
# 原因：Homebrew 升级 node 是全局的，容易破坏其他项目；
#       NVM 可以按项目隔离版本，互不干扰。
#
# 安装 NVM（从官方获取最新安装命令）：
#   https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
#
#   ⚠️  安装脚本会自动在 ~/.zshrc 末尾追加三行 NVM 初始化代码，
#       安装完成后需手动删除，因为本文件已统一处理，重复 source 无意义。
#
# 安装 Node（推荐使用 LTS 版本，即长期支持版，稳定适合生产环境）：
#   nvm install --lts        # 下载安装最新 LTS 版本
#   nvm use --lts            # 当前终端窗口立即切换生效
#   nvm alias default lts/*  # 设为默认，新开终端自动使用（lts/* 始终指向最新 LTS）
#
# 安装指定版本（如项目要求特定版本）：
#   nvm install 22           # 安装指定大版本（自动取该大版本最新）
#   nvm install 22.14.0      # 安装精确版本
#   nvm use 22               # 当前终端切换到该版本
#   nvm alias default 22     # 设为默认（锁死版本，不会自动跟随升级）
#
# 为项目单独指定 Node 版本：
#   1. 在项目根目录创建 .nvmrc 文件：echo "22" > .nvmrc
#   2. 进入项目目录后执行：nvm use
#   3. 或依靠下方 hook，cd 进目录时自动切换（无需手动执行）
#
# 此文件已在 ~/.zshrc 第 104 行统一 source，各主机的 local zshrc 无需重复引入。
# ========================================

export NVM_DIR="$HOME/.nvm"

# ---- 启动加速：lazy-load NVM ----
# NVM 启动时会扫描版本并执行默认版本切换，是新建终端最主要的耗时来源。
# 这里先把默认 Node 版本的 bin 放进 PATH，首次显式调用 nvm 或进入含 .nvmrc 的目录时再加载完整 NVM。
_nvm_add_default_to_path() {
  local default_version node_bin
  local -a candidate_bins

  [[ -r "$NVM_DIR/alias/default" ]] || return
  default_version="$(<"$NVM_DIR/alias/default")"

  case "$default_version" in
    v*) candidate_bins=("$NVM_DIR/versions/node/${default_version}"*/bin(Nn)) ;;
    [0-9]*) candidate_bins=("$NVM_DIR/versions/node/v${default_version}"*/bin(Nn)) ;;
    *) return ;;
  esac

  for node_bin in ${(On)candidate_bins}; do
    [[ -x "$node_bin/node" ]] || continue
    case ":$PATH:" in
      *":$node_bin:"*) ;;
      *) export PATH="$node_bin:$PATH" ;;
    esac
    break
  done
}

_nvm_lazy_load() {
  unfunction nvm 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

nvm() {
  _nvm_lazy_load
  nvm "$@"
}

_nvm_add_default_to_path

# ---- 自动切换 Node 版本 ----
# 进入含有 .nvmrc 的目录时，加载 NVM 并自动切换到对应 Node 版本。
autoload -U add-zsh-hook
add-zsh-hook chpwd load-nvmrc
load-nvmrc() {
  if [ -f .nvmrc ]; then
    _nvm_lazy_load
    nvm use
  fi
}
load-nvmrc
