# 从 Dotbot 迁移到 dotdrop

## 目的

本仓库当前用 Dotbot 通过符号链接部署配置。实际需要解决的问题只有一个：Herdr GPUI 拒绝符号链接形式的共享配置（要求 owned regular file），设置页底部长期显示 Unavailable。

顺带要修的是映射表本身没想清楚：现在是「把 `zsh/`、`vim/`、`tmux/` 整目录链回家目录」，等于把仓库内容与运行时克隆的插件混在同一个目录条目里，26 条映射里有一半是不必要的。

迁移目标：改用 dotdrop，**默认符号链接**（保持「仓库只有一份」的模型），**只把 Herdr 共享配置改成复制**。映射表从 26 条缩到 16 条。

## 核心模型

判定一个文件要不要映射，看**谁决定它的路径**：

| 类别 | 判定 | 处理 |
|---|---|---|
| 程序按固定路径查找 | 不放到那个路径功能就不生效 | **必须映射** |
| 被上面那种文件主动 source / require | 路径写在引用方手里，可随意 | **不映射**，只留仓库一份 |

zsh 是第二类的典型。`~/.zshrc` 是 zsh 硬编码要读的，必须映射；`zsh/zle.zsh`、`zsh/aliases/*.zsh` 是被 `zshrc` 里那行 `source ~/.dotfiles/zsh/zle.zsh` 拉进来的，路径由我们自己写，所以**不需要**在 `~/.zsh/` 留副本。`~/.zsh/aliases/` 那份复制品目前没有任何东西读。

推论：**只映射 16 条，全部用链接，除了 Herdr 那一条用复制。**

链接的好处正是「只有一份」：改 `zsh/zshrc` 立即生效，没有 install 延迟。复制才有两份，才有漂移。Herdr 是例外，因为它的 GPUI 显式拒绝链接。

## 现状盘点

### 当前 Dotbot 映射（26 条）

`install.conf.yaml` 的 link 段。按上面的模型分类：

**必须映射（16 条）**

| 目标 | 源 | 谁要求这个路径 |
|---|---|---|
| `~/.zshrc` | `zsh/zshrc` | zsh 硬编码 |
| `~/.zshenv` | `zsh/zshenv` | zsh 硬编码 |
| `~/.zprofile` | `zsh/zprofile` | zsh 硬编码 |
| `~/.p10k.zsh` | `zsh/p10k.zsh` | `zsh/zshrc:9` 写死的路径 |
| `~/.bashrc` | `bash/bashrc` | bash 硬编码 |
| `~/.profile` | `bash/profile` | bash 硬编码 |
| `~/.inputrc` | `bash/inputrc` | readline 硬编码 |
| `~/.gitconfig` | `git/gitconfig` | git 硬编码 |
| `~/.claude/CLAUDE.md` | `agents/CLAUDE.md` | Claude Code 硬编码 |
| `~/.codex/AGENTS.md` | `agents/CODEX.md` | Codex 硬编码 |
| `~/.hammerspoon/` | `hammerspoon` | Hammerspoon 硬编码（整目录，不产生纠缠） |
| `~/.config/yazi/` | `yazi` | Yazi 默认配置目录 |
| `~/.config/kitty/` | `kitty` | kitty 默认配置目录 |
| `~/.config/lazygit/` | `lazygit` | lazygit 默认配置目录 |
| `~/.config/atuin/` | `atuin` | atuin 默认配置目录 |
| `~/.config/herdr/` 三件套 | `herdr/{config.toml,host-status.sh,*.py}` | herdr 默认目录 + `config.toml` 里写死的 `~/.config/herdr/host-status.sh` |

另外还有 4 条属于这一类但需要单独说明：

| 目标 | 源 | 说明 |
|---|---|---|
| `~/.config/karabiner/` | `karabiner` | 目录里混有被忽略的 `karabiner.json`（运行时生成）和 `automatic_backups/` |
| `~/.config/ghostty/` | `ghostty` | 本机没装 Ghostty，映射指向不存在的程序 |
| `~/.config/hunk/config.toml` | `hunk/config.toml` | hunk 默认路径 |
| `~/.config/herdr/*.py` | `herdr/*.py` | 其中 `codex-usage.py` 已不再被 `tab_bar_right` 调用 |

**不需要映射（10 条，可直接删除）**

| 目标 | 处理 |
|---|---|
| `~/.zsh/` | 删除。只保留 `~/.zsh/plugins/`，由 `zsh/install_plugins.sh` 克隆 |
| `~/.vim/` | 删除。`vim/vimrc` 内部用的是绝对路径，插件目录由 `vim/install_plugins.sh` 创建 |
| `~/.tmux/`、`~/.tmux.conf` | 已在本轮退役（commit `ea58879`） |

`~/.zsh/` 和 `~/.vim/` 的问题在于自相矛盾：`zsh/plugins/` 和 `vim/pack/vendor/` 被 `.gitignore` 忽略，却被符号链接把整个父目录暴露出去，等于把「仓库内容」和「运行时克隆的插件」混在同一个目录条目里。

### 必须排除的内容

这些路径不能进 dotdrop 的 `src`，否则 `install` 会用空目录覆盖家目录、`update` 会把运行时状态收进仓库：

| 路径 | 体积 | 原因 |
|---|---|---|
| `zsh/plugins/` | 10 个第三方插件 | `.gitignore` 忽略，`zsh/install_plugins.sh` 克隆 |
| `vim/pack/vendor/` | 11 个第三方插件 | `.gitignore` 忽略，`vim/install_plugins.sh` 克隆 |
| `lazygit/state.yml` | 运行时状态 | `.gitignore` 忽略，lazygit 写入 |
| `karabiner/karabiner.json` | 运行时生成 | `.gitignore` 忽略，Karabiner 写入 |
| `karabiner/automatic_backups/` | 自动备份 | `.gitignore` 忽略 |
| `zsh/hosts/*.secret*` | 私密配置 | `.gitignore` 忽略 |
| `.deprecated/tmux/plugins/` | tpm 及插件 | `.gitignore` 忽略（本轮退役后） |

## dotdrop 配置方案

### 目录布局

`dotpath` 设为仓库根目录，`src` 直接用现有路径，**不动任何文件位置**：

```yaml
config:
  dotpath: .
  link_dotfile_default: absolute   # 默认链接
  backup: true                     # 覆盖前留 .dotdropbak
  create: true
  force_chmod: true                # 保住脚本的可执行位
```

### 完整 config.yaml

```yaml
config:
  dotpath: .
  link_dotfile_default: absolute
  backup: true
  create: true
  force_chmod: true
  cmpignore:
    - '*/plugins/*'
    - '*/pack/vendor/*'
    - '*/automatic_backups/*'
    - '*/state.yml'
    - '*.secret*'
  instignore:
    - '*/plugins/*'
    - '*/pack/vendor/*'
    - '*/automatic_backups/*'
  upignore:
    - '*/plugins/*'
    - '*/pack/vendor/*'
    - '*/automatic_backups/*'
    - '*/state.yml'
    - '*/karabiner.json'

dotfiles:
  # --- shell ---
  f_bashrc:
    src: bash/bashrc
    dst: ~/.bashrc
  f_profile:
    src: bash/profile
    dst: ~/.profile
  f_inputrc:
    src: bash/inputrc
    dst: ~/.inputrc
  f_zshenv:
    src: zsh/zshenv
    dst: ~/.zshenv
  f_zprofile:
    src: zsh/zprofile
    dst: ~/.zprofile
  f_zshrc:
    src: zsh/zshrc
    dst: ~/.zshrc
  f_p10k:
    src: zsh/p10k.zsh
    dst: ~/.p10k.zsh

  # --- git ---
  f_gitconfig:
    src: git/gitconfig
    dst: ~/.gitconfig

  # --- agents ---
  f_claude_md:
    src: agents/CLAUDE.md
    dst: ~/.claude/CLAUDE.md
  f_codex_agents:
    src: agents/CODEX.md
    dst: ~/.codex/AGENTS.md

  # --- apps ---
  d_hammerspoon:
    src: hammerspoon
    dst: ~/.hammerspoon
  d_yazi:
    src: yazi
    dst: ~/.config/yazi
  d_kitty:
    src: kitty
    dst: ~/.config/kitty
  d_lazygit:
    src: lazygit
    dst: ~/.config/lazygit
    upignore:
      - '*/state.yml'
  d_atuin:
    src: atuin
    dst: ~/.config/atuin
  d_ghostty:
    src: ghostty
    dst: ~/.config/ghostty
  d_karabiner:
    src: karabiner
    dst: ~/.config/karabiner
    upignore:
      - '*/karabiner.json'
      - '*/automatic_backups/*'
  f_hunk:
    src: hunk/config.toml
    dst: ~/.config/hunk/config.toml

  # --- herdr ---
  f_herdr_config:
    src: herdr/config.toml
    dst: ~/.config/herdr/config.toml
    link: nolink              # GPUI 拒绝符号链接，本条必须复制
  f_herdr_host_status:
    src: herdr/host-status.sh
    dst: ~/.config/herdr/host-status.sh
  f_herdr_mac_power:
    src: herdr/mac-power.py
    dst: ~/.config/herdr/mac-power.py
  f_herdr_codex_usage:
    src: herdr/codex-usage.py
    dst: ~/.config/herdr/codex-usage.py
  f_herdr_commandcode_usage:
    src: herdr/commandcode-usage.py
    dst: ~/.config/herdr/commandcode-usage.py

profiles:
  mba:
    dotfiles: ALL
  macmini:
    dotfiles: ALL
  ycy-2C2G:
    dotfiles: ALL
```

`~/.claude/` 和 `~/.codex/` 是外部工具管理的目录，dotdrop 的 `create: true` 会按需创建父目录，不会碰目录里的其他文件。

### 唯一一条 nolink

`f_herdr_config` 是全部配置里唯一需要复制的。代价是：

- 改 `herdr/config.toml` 后要 `dotdrop install` 才生效
- Herdr GUI 写入后要 `dotdrop update` 收进仓库
- 两侧漂移用 `dotdrop compare` 看

这一条可以接受，因为它就是本次迁移的直接起因。

## 清理清单

### 要删除的

| 对象 | 处理 |
|---|---|
| `install.conf.yaml` | 删除，映射迁入 `config.yaml` |
| `install.conf.README.txt` | 删除，Dotbot 专用的操作说明 |
| `dotbot/` 子模块 | `git submodule deinit -f dotbot`、`git rm -f dotbot`、删 `.git/modules/dotbot`，并删 `.gitmodules` 里的 `submodule.dotbot.*` 四条 |
| `init_dotfiles.sh` | 删除。它是 Dotbot 仓库的配置生成器，全仓库无引用（`grep -rn init_dotfiles` 只命中自身） |
| `.idea/vcs.xml` 里的 dotbot 映射 | 该文件未被 git 跟踪，可删或手工编辑，不影响仓库 |
| `.gitmodules` 里 vim 的三条 | 见「待你决定的问题」第 2 条 |

### 要改写的

| 对象 | 改动 |
|---|---|
| `install` | 改为调用 `dotdrop --cfg config.yaml install --profile <host>`；保留 `set -e`；保留 submodule 与插件安装逻辑；增加「先摘掉旧符号链接」的步骤 |
| `zsh/aliases.sh` 的 `dfu()` | 行为不变（`git pull --ff-only` + `./install` + `exec zsh`），但 `install` 语义变化需要在提示语里说明 |
| `README.md` / `README-en.md` | 「基于 Dotbot 的一键安装」改为 dotdrop；「如果某些文件已存在，需要先删除」那段按 dotdrop 的 `backup: true` 行为重写；目录结构一节删掉 `tmux/` |
| `CHANGELOG.md` | 追加迁移条目 |
| `.gitmodules` | 删掉 dotbot 段；vim 三条见第 2 条 |
| `context.md`、`research.md` | 未被跟踪，不涉及 |

### 要新增的

| 对象 | 用途 |
|---|---|
| `config.yaml` | dotdrop 配置 |
| `install` 增加 dotdrop 可用性检查 | 未安装时提示 `brew install dotdrop` |

## 迁移步骤

### 阶段 0：准备

1. 在本地和 macmini 各跑一次「家目录有哪些文件仓库里没有」的清点，确认没有只存在于家目录的配置。重点检查 `zsh/hosts/`、`karabiner/`、`lazygit/`。
2. `brew install dotdrop`（本地与所有远程机器）。依赖是 `certifi`、`libmagic`、`python@3.14`。
3. 确认所有机器的仓库都是干净工作树。

### 阶段 1：建立配置

1. 新增 `config.yaml`，映射照抄上表。
2. `dotdrop compare -c config.yaml` 看差异，确认 src/dst 解析正确。
3. `dotdrop install --dry -c config.yaml` 预演，确认不触碰 `plugins/`、`pack/vendor/`。

### 阶段 2：本机切换

1. 逐个摘掉现有符号链接。**注意 `~/.zsh/` 和 `~/.vim/` 要保留目录本身**，只删链接后重建为普通目录（插件在里面）：

   ```sh
   for f in ~/.bashrc ~/.profile ~/.inputrc ~/.gitconfig ~/.p10k.zsh ~/.zshenv ~/.zprofile ~/.zshrc; do
     [ -L "$f" ] && rm -f "$f"
   done
   for d in ~/.hammerspoon ~/.config/yazi ~/.config/kitty ~/.config/lazygit \
            ~/.config/atuin ~/.config/ghostty ~/.config/karabiner; do
     [ -L "$d" ] && rm -f "$d"
   done
   # ~/.zsh 和 ~/.vim 在新方案里不再是链接，摘掉后插件目录仍在原位
   [ -L ~/.zsh ] && { rm -f ~/.zsh; mkdir -p ~/.zsh; mv ~/.zsh.bak-plugins ~/.zsh/plugins; }
   ```
   `~/.zsh` 和 `~/.vim` 的摘链需要特殊处理：它们是链接时插件实际在仓库里（`zsh/plugins/`），摘掉链接后要先把插件目录移到新位置，否则 `mkdir` 出来的空目录没有插件。这一步的具体命令见「待你决定的问题」第 3 条。

2. `dotdrop install -c config.yaml`，生成映射。
3. 逐个功能验证：新开 zsh（插件、缩写、别名、prompt）、vim（插件加载）、hammerspoon 重载、yazi、kitty、lazygit、atuin、Herdr 设置页底部不再显示 Unavailable。
4. 验证插件目录未被清空：`~/.zsh/plugins/`、`~/.vim/pack/vendor/start/`。

### 阶段 3：清理 Dotbot

1. 删 `install.conf.yaml`、`install.conf.README.txt`、`init_dotfiles.sh`。
2. 移除 dotbot 子模块与 `.gitmodules` 条目。
3. 改写 `install` 为 dotdrop 调用。
4. 更新 README 两份与 CHANGELOG。
5. 提交。

### 阶段 4：远程机器

每台机器（macmini、ycy-2C2G、lz-ycy-4C8G、autodl 容器等）：

1. `git pull`。
2. `brew install dotdrop`（Linux 上用 `pipx install dotdrop` 或发行版包）。
3. 执行阶段 2 第 1 步的摘链 loop。**这一步必需**，否则残留链接会与新部署冲突。
4. `dotdrop install -c config.yaml`。
5. `dfu` 验证：`git pull --ff-only` + `./install` + `exec zsh` 全程无报错。

### 阶段 5：回滚

迁移前打 tag：`git tag pre-dotdrop`。阶段 3 删掉 Dotbot 之前，回滚只需 `git checkout pre-dotdrop`；之后需要 `git revert` 迁移提交。

## 风险

| 风险 | 影响 | 缓解 |
|---|---|---|
| 摘掉 `~/.zsh` / `~/.vim` 链接时丢插件 | 插件目录被删，shell 与 vim 起不来 | 摘链前先把 `zsh/plugins/` 和 `vim/pack/` 移出，或改用手工逐个处理这两个目录 |
| `install` 语义从「建链接」变为「建链接 + 复制一个文件」 | Herdr 配置被仓库版本覆盖 | `backup: true` 留 `.dotdropbak`；迁移前先 `dotdrop compare` |
| 目录条目 `nolink` 复制插件 | 复制上万个文件，慢且占空间 | `instignore` 排除 `*/plugins/*`、`*/pack/vendor/*` |
| 权限位丢失 | `host-status.sh`、`codex-usage.py` 失去可执行位 | `force_chmod: true` |
| 远程机器忘记摘旧链接 | `dotdrop install` 报冲突 | `install` 脚本内置摘链 loop |
| 运行时文件被 `update` 收进仓库 | `karabiner.json`、`state.yml` 进 git | `upignore` 显式排除 |
| dotdrop 只在 macOS/Linux 可用 | 无 Windows 支持 | 本仓库本来就没有 Windows 目标 |

## 验证方式

每阶段完成后手工验证，不写自动化测试：

- `dotdrop compare -c config.yaml` 无输出：src 与 dst 一致。
- `dotdrop install --dry -c config.yaml` 不触碰插件目录。
- 阶段 2 第 3 步的功能清单逐项通过。
- `dotdrop update -c config.yaml` 之后 `git status` 只显示预期改动。
- 远程机器 `dfu` 后 `exec zsh` 进入新 shell 无报错。

## 待你决定的问题

1. **`zsh/hosts/local_index.sh` 的目录归属。**
   该脚本在缺主机文件时会 `touch` 新建。当前指向 `$HOME/.dotfiles/zsh/hosts`，新增的主机文件会被 git 跟踪。如果改成 `~/.zsh/hosts`，则新文件不进仓库、需要另配一条映射。建议保持现状（仓库路径），因为新增的主机配置本来就该进 git。

2. **vim 的三条 `.gitmodules` 残留是否一并删除。**
   `.gitmodules` 里有 `vim/pack/vendor/start/nerdtree`、`vim-tmux-clipboard`、`vim-tmux-focus-events` 三条，但 git 索引里**没有**对应 gitlink（只有 `dotbot` 一个），指向的目录还被 `.gitignore` 忽略。也就是历史残留，目录由 `vim/install_plugins.sh` 克隆。建议随本次迁移一并删除这三条记录和对应的 `.git/modules/vim/...` 缓存。要你确认。

3. **`~/.zsh` 和 `~/.vim` 摘链的具体手法。**
   两者当前都是指向仓库的符号链接，插件实际在 `zsh/plugins/` 和 `vim/pack/vendor/`。摘掉链接后插件必须留在 `~/.zsh/plugins/`、`~/.vim/pack/vendor/`，而仓库里那两份要被 gitignore 忽略。
   方案：先用 `cp -a` 把插件目录复制到临时位置，再摘链、建目录、移回。或者更稳的做法是**保留这两个目录的链接不摘**，接受它们继续指向仓库（插件照旧被忽略，重复内容是摆设但不影响运行），只在 config.yaml 里给这两条加 `instignore` 排除插件路径。
   建议后者：改动小、无数据风险，代价是 `~/.zsh/aliases/` 那些副本继续存在。要你选。

4. **是否给整目录条目改用链接而非复制。**
   本方案已定：全部链接，只有 Herdr 复制。无需再决。

## 附：Dotbot 与 dotdrop 行为对照

| 场景 | Dotbot（现在） | dotdrop（迁移后） |
|---|---|---|
| 部署文件 | 建符号链接 | 默认链接，逐条可改复制 |
| 改仓库文件后 | 立即生效 | 立即生效（`nolink` 的条目需 `install`） |
| 改家目录文件后 | 改的就是仓库文件 | `nolink` 条目需 `update` |
| 家目录已有文件 | 报错要求手删 | `backup: true` 留 `.dotdropbak` 后覆盖 |
| 按主机裁剪 | 无 | profiles |
| 忽略子目录 | 无 | `instignore` / `upignore` / `cmpignore` |
| 加密 | 无 | `trans_install` / `trans_update` |
| 模板 | 无 | 支持 |
| 权限 | 继承源文件 | `chmod` 条目或 `force_chmod` |
| 命令 | `./install` | `dotdrop install` / `update` / `compare` |
