# 从 Dotbot 迁移到 dotdrop

## 目的

本仓库当前用 Dotbot 通过符号链接部署配置。实际需要解决的问题只有一个：Herdr GPUI 拒绝符号链接形式的共享配置（要求 owned regular file），设置页底部长期显示 Unavailable。

顺带要修的是映射表本身没想清楚：现在是「把 `zsh/`、`vim/`、`tmux/` 整目录链回家目录」，等于把仓库内容与运行时克隆的插件混在同一个目录条目里，26 条映射里有一半是不必要的。

迁移目标：改用 dotdrop，**默认符号链接**（保持「仓库只有一份」的模型），**只把 Herdr 共享配置改成复制**。映射表从 26 条缩到 24 条。

## 核心模型

判定一个文件要不要映射，看**谁决定它的路径**：

| 类别 | 判定 | 处理 |
|---|---|---|
| 程序按固定路径查找 | 不放到那个路径功能就不生效 | **必须映射** |
| 被上面那种文件主动 source / require | 路径写在引用方手里，可随意 | **不映射**，只留仓库一份 |

zsh 是第二类的典型。`~/.zshrc` 是 zsh 硬编码要读的，必须映射；`zsh/zle.zsh`、`zsh/aliases/*.zsh` 是被 `zshrc` 里那行 `source ~/.dotfiles/zsh/zle.zsh` 拉进来的，路径由我们自己写，所以**不需要**在 `~/.zsh/` 留副本。`~/.zsh/aliases/` 那份复制品目前没有任何东西读。

推论：**实际映射 24 条，全部用链接，除了 Herdr 那条用复制。**

链接的好处正是「只有一份」：改 `zsh/zshrc` 立即生效，没有 install 延迟。复制才有两份，才有漂移。Herdr 是例外，因为它的 GPUI 显式拒绝链接。

## 现状盘点

### 当前 Dotbot 映射（26 条）

`install.conf.yaml` 的 link 段。按上面的模型分类：

**必须映射（20 条，原表 16 条 + 下面 4 条）**

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
| `~/.zsh/` | 删除。`zsh/` 下的配置与插件改为由 `$DOTFILES` 直接引用，见下节 |
| `~/.vim/` | 删除。`vimrc` 用 `packpath` 直接指向仓库，见下节 |
| `~/.tmux/`、`~/.tmux.conf` | 已在本轮退役（commit `ea58879`） |

`~/.zsh/` 和 `~/.vim/` 原先的问题在于自相矛盾：`zsh/plugins/` 和 `vim/pack/vendor/` 被 `.gitignore` 忽略，却被符号链接把整个父目录暴露出去，等于把「仓库内容」和「运行时克隆的插件」混在同一个目录条目里。

**已在 2026-10-06 解决**：不再映射这两个目录，改为让配置自己指向仓库。

- `zsh/zshenv` 导出 `DOTFILES="$HOME/.dotfiles"`，`zshrc`、`fzf.zsh`、`aliases.sh`、`hosts/local_index.sh` 里的插件与子配置引用全部改用该变量。
- `vim/vimrc` 开头加 `let &packpath = expand('$HOME/.dotfiles/vim') . ',' . &packpath`，插件从仓库加载；用 `let` 而非 `set packpath^=`，因为后者的 `$HOME` 会被 vim 保留为字面量（实测）。

两个改动都不依赖 `~/.zsh`、`~/.vim` 链接存在，实测把链接移走后 zsh 的 prompt/缩写/插件与 vim 的 8 个插件均正常加载。

### 必须排除的内容

这些路径不能进 dotdrop 的 `src`，否则 `install` 会用空目录覆盖家目录、`update` 会把运行时状态收进仓库：

| 路径 | 体积 | 原因 |
|---|---|---|
| `zsh/plugins/` | 9 个第三方插件 | `.gitignore` 忽略，`zsh/install_plugins.sh` 克隆 |
| `vim/pack/vendor/` | 8 个第三方插件 | `.gitignore` 忽略，`vim/install_plugins.sh` 克隆 |
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
    - '*/automatic_backups/*'
    - '*/state.yml'
    - '*.secret*'
  instignore:
    - '*/automatic_backups/*'
  upignore:
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
  default:
    dotfiles: ALL
```

`~/.claude/` 和 `~/.codex/` 是外部工具管理的目录，dotdrop 的 `create: true` 会按需创建父目录，不会碰目录里的其他文件。

### profile 只留一个

profile 是「一组 dotfiles 的选集」，命令形如 `dotdrop -p <名字> install`。原方案按机器名写了 `mba`、`macmini`、`ycy-2C2G` 三份，但三份内容都是 `ALL`，等于没有裁剪，代价是每台机器必须传对 `--profile`，而 dotdrop 默认 profile 取当前主机名，新主机名上还会直接报 `no dotfile defined for this profile`。留一个 `default: ALL`，命令不用带 `-p`（或显式 `-p default`），将来真要按主机裁剪再加。

### 唯一一条 nolink

`f_herdr_config` 是全部配置里唯一需要复制的。代价是：

- 改 `herdr/config.toml` 后要 `dotdrop install` 才生效
- Herdr GUI 写入后要 `dotdrop update` 收进仓库
- 两侧漂移用 `dotdrop compare` 看

这一条可以接受，因为它就是本次迁移的直接起因。**落地时家目录那份才是要保留的版本**：家目录是 `delivery = "system"`，仓库里是 09-24 提交的 `terminal`。先 `cp ~/.config/herdr/config.toml herdr/config.toml` 收回仓库再安装，否则 `nolink` 会用旧值盖掉正在用的设置。

## 清理清单

### 要删除的

| 对象 | 处理 |
|---|---|
| `install.conf.yaml` | 删除，映射迁入 `config.yaml` |
| `install.conf.README.txt` | 删除，Dotbot 专用的操作说明 |
| `dotbot/` 子模块 | `git submodule deinit -f dotbot`、`git rm -f dotbot`、删 `.git/modules/dotbot`，并删 `.gitmodules` 里的 `submodule.dotbot.*` 四条 |
| `init_dotfiles.sh` | 删除。它是 Dotbot 仓库的配置生成器，全仓库无引用（`grep -rn init_dotfiles` 只命中自身） |
| `.idea/vcs.xml` 里的 dotbot 映射 | 该文件未被 git 跟踪，可删或手工编辑，不影响仓库 |
| `.gitmodules` 里 vim 的三条 | **已完成**，见 commit `494ca5b` |

### 要改写的

| 对象 | 改动 |
|---|---|
| `install` | 改为调用 `dotdrop --cfg config.yaml install`（单 `default` profile，不传 `--profile`）；保留 `set -e`；保留插件安装逻辑；增加「先删掉旧符号链接」的步骤（用 `[ -L ]` 判定后再 `rm -f`） |
| `zsh/aliases.sh` 的 `dfu()` | 行为不变（`git pull --ff-only` + `./install` + `exec zsh`），但 `install` 语义变化需要在提示语里说明 |
| `README.md` / `README-en.md` | 「基于 Dotbot 的一键安装」改为 dotdrop；「如果某些文件已存在，需要先删除」那段按 dotdrop 的 `backup: true` 行为重写；目录结构一节已删 `tmux/`（commit `ea58879`） |
| `CHANGELOG.md` | 追加迁移条目 |
| `.gitmodules` | 删掉 dotbot 段（vim 三条已在 `494ca5b` 删除） |
| `context.md`、`research.md` | 未被跟踪，不涉及 |

### 要新增的

| 对象 | 用途 |
|---|---|
| `config.yaml` | dotdrop 配置 |
| `install` 增加 dotdrop 可用性检查 | 未安装时提示 `brew install dotdrop` |

## 迁移步骤

### 阶段 0：准备

1. 在本地和 macmini 各跑一次「家目录有哪些文件仓库里没有」的清点，确认没有只存在于家目录的配置。重点检查 `zsh/hosts/`、`karabiner/`、`lazygit/`。
2. 安装 dotdrop。macOS 14 上 `brew install dotdrop` 会源码重建 7 个依赖（含 `python@3.14`、`openssl@3`），本机实测卡在 openssl 源码包下载；改用 pipx 路线：`pipx install dotdrop` + `brew install libmagic` + `pipx inject --force dotdrop python-magic`。仅 `pipx install` 会报 `missing python module python-magic`，缺了 libmagic 则 `import magic` 失败，这条 `inject` 不能省。
3. 确认所有机器的仓库都是干净工作树。

### 阶段 1：建立配置

1. 新增 `config.yaml`，映射照抄上表。
2. `dotdrop -c config.yaml -p default compare` 看差异，确认 src/dst 解析正确。单 profile 也需显式 `-p default`，否则按当前主机名取 profile。
3. `dotdrop -c config.yaml -p default install --dry` 预演，确认不触碰 `zsh/plugins/`、`vim/pack/`（`~/.zsh`、`~/.vim` 已不在映射表里，正常不会被引用）。

### 阶段 2：本机切换

顺序是先删旧链接，再部署新映射。

#### 2.1 删掉 zsh 与 vim 的目录链接

`zsh/zshenv` 现在导出 `DOTFILES`，`vimrc` 用 `packpath` 指向仓库，插件与子配置都已按仓库路径引用，所以 `~/.zsh`、`~/.vim` 这两条链接可以直接删除，不需要搬家、不需要重装插件。

```sh
[ -L ~/.zsh ] && rm -f ~/.zsh
[ -L ~/.vim ] && rm -f ~/.vim
```

删之前先确认两件事：

1. `$DOTFILES` 已生效：`zsh -i -c 'echo $DOTFILES'` 输出 `$HOME/.dotfiles`。
2. 没有别的东西依赖这两个路径。检查方式：临时 `mv ~/.zsh ~/.zsh.bak`、`mv ~/.vim ~/.vim.bak`，开一个新 shell 看 prompt/缩写/补全是否正常，`vim` 打开文件看 `:scriptnames` 是否列出仓库插件，确认后再删。

这两条删完，仓库里的 `zsh/plugins/`、`vim/pack/vendor/` 就是插件的唯一位置，`zsh/install_plugins.sh`、`vim/install_plugins.sh` 照旧克隆到那里（脚本里写的是 `~/.zsh/plugins/`，若链接已删需要改成 `$DOTFILES/zsh/plugins/`）。

#### 2.2 删掉其余旧链接

```sh
for f in ~/.bashrc ~/.profile ~/.inputrc ~/.gitconfig ~/.p10k.zsh ~/.zshenv ~/.zprofile ~/.zshrc; do
  [ -L "$f" ] && rm -f "$f"
done
for d in ~/.hammerspoon ~/.config/yazi ~/.config/kitty ~/.config/lazygit \
         ~/.config/atuin ~/.config/ghostty ~/.config/karabiner; do
  [ -L "$d" ] && rm -f "$d"
done
```

#### 2.3 部署与验证

1. `dotdrop install -c config.yaml`。
2. 逐个功能验证：新开 zsh（插件、缩写、补全、prompt）、vim（`:scriptnames` 列出 8 个仓库插件）、hammerspoon 重载、yazi、kitty、lazygit、atuin、Herdr 设置页底部不再显示 Unavailable。
3. 验证插件仍在：`$DOTFILES/zsh/plugins/` 9 个、`$DOTFILES/vim/pack/vendor/start/` 8 个。

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
3. 执行阶段 2.1 与 2.2 的删链接步骤。**这一步必需**，否则残留链接会与新部署冲突。
4. `dotdrop install -c config.yaml`。
5. `dfu` 验证：`git pull --ff-only` + `./install` + `exec zsh` 全程无报错。

### 阶段 5：回滚

迁移前打 tag：`git tag pre-dotdrop`。阶段 3 删掉 Dotbot 之前，回滚只需 `git checkout pre-dotdrop`；之后需要 `git revert` 迁移提交。

## 风险

| 风险 | 影响 | 缓解 |
|---|---|---|
| 删掉 `~/.zsh` / `~/.vim` 后发现仍有引用 | shell 或 vim 找不到插件 | 删之前先 `mv` 改名验证一轮；即使漏了，插件仍在仓库，`install_plugins.sh` 可重装 |
| `install` 语义从「建链接」变为「建链接 + 复制一个文件」 | Herdr 配置被仓库版本覆盖 | `backup: true` 留 `.dotdropbak`；迁移前先 `dotdrop compare` |
| 权限位丢失 | `host-status.sh`、`codex-usage.py` 失去可执行位 | `force_chmod: true` |
| 远程机器残留旧符号链接 | `dotdrop install` 报冲突 | `install` 脚本内置删链接的 loop |
| 运行时文件被 `update` 收进仓库 | `karabiner.json`、`state.yml` 进 git | `upignore` 显式排除 |
| dotdrop 只在 macOS/Linux 可用 | 无 Windows 支持 | 本仓库本来就没有 Windows 目标 |

## 验证方式

每阶段完成后手工验证，不写自动化测试：

- `dotdrop compare -c config.yaml` 无输出：src 与 dst 一致。
- `dotdrop install --dry -c config.yaml` 不触碰插件目录。
- 阶段 2 第 3 步的功能清单逐项通过。
- `dotdrop update -c config.yaml` 之后 `git status` 只显示预期改动。
- 远程机器 `dfu` 后 `exec zsh` 进入新 shell 无报错。

## 已定的决策

1. **`zsh/hosts/local_index.sh` 保持仓库路径。** 该脚本在缺主机文件时 `touch` 新建，指向 `$HOME/.dotfiles/zsh/hosts` 时新增的主机配置会被 git 跟踪，符合预期。
2. **vim 的 `.gitmodules` 三条残留已删除。** nerdtree、vim-tmux-clipboard、vim-tmux-focus-events 三条记录在 commit `494ca5b` 中清掉；`git ls-files -s` 从头到尾只列出 `dotbot` 一个 gitlink，这些目录一直由 `install_plugins.sh` 克隆。`.git/modules/vim/` 不存在，无需清理。
3. **默认链接，只有 Herdr 复制。** 不做逐目录评估。
4. **插件留在仓库，`~/.zsh` 与 `~/.vim` 两条链接删除。** 配置改为自己指向仓库：`zshenv` 导出 `DOTFILES`，`vimrc` 用 `packpath`。已落地并实测（把两个链接物理移走后 zsh 与 vim 仍正常加载插件）。
5. **删链接先做 `[ -L ]` 判定。** `install.conf.yaml` 的 shell 段与将来 `install` 脚本里的删链接步骤统一写成 `[ -L 路径 ] && rm -f 路径`，不用无条件 `rm -f`。
6. **`install_plugins.sh` 的 clone 目标已是 `$DOTFILES`。** 两个脚本都改成 `${DOTFILES:-$HOME/.dotfiles}/...`，不依赖已删除的 `~/.zsh`、`~/.vim` 链接。
7. **profile 只留一个 `default: ALL`。** 原方案的三份按主机名的 profile 内容相同，等于没有裁剪，却要求每台机器传对 `--profile`，新主机名还会因缺 profile 报 `no dotfile defined for this profile`。
8. **Herdr 配置以家目录版为准。** 家目录在用 `delivery = "system"`，仓库里是 09-24 提交的 `terminal`，两侧已漂移。`nolink` 会用仓库版覆盖家目录版，所以先 `cp ~/.config/herdr/config.toml herdr/config.toml` 收回仓库再安装。

## 待你决定的问题

暂无。原两条已在 2026-10-06 落地：

- `install_plugins.sh` 的 clone 目标改成 `${DOTFILES:-$HOME/.dotfiles}/...`，已实测克隆到仓库。
- 删链接一律用 `[ -L 路径 ] && rm -f 路径` 判定后再删，不用无条件 `rm -f`，避免误删同名普通文件。

## 落地记录（本机 mba，2026-10-06）

- 迁移前打 tag `pre-dotdrop`（`df020fc`）。
- dotdrop 1.17.0 经 pipx 安装，`python-magic` 已 inject。
- `dotdrop compare` 首次只有 `mac-power.py` 未链；`install` 后 `compare` 无输出，24 条 dotfile 全部一致。
- `~/.config/herdr/config.toml` 是普通文件且与仓库一致；其余 23 条仍是绝对符号链接，未重复重链。
- 验证通过：`DOTFILES` 生效、abbr 71 条、p10k 加载、`$fpath` 含仓库两目录、`z` 命令可用（`abbr list` 在非交互 `zsh -i -c` 下报 `can't change option: zle` 属正常）；`&packpath` 为 `/Users/tony/.dotfiles/vim` 且 `globpath` 列出 8 个仓库插件；`zsh/plugins` 9 个、`vim/pack/vendor/start` 8 个仍在。

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
