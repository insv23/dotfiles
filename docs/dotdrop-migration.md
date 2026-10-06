# 从 Dotbot 迁移到 dotdrop

## 目的

本仓库当前用 Dotbot 通过符号链接部署配置。符号链接在三处造成实际问题：

1. Herdr GPUI 拒绝符号链接形式的共享配置（要求 owned regular file），设置页底部长期显示 Unavailable。
2. 家目录里所有配置都是链接，任何工具写入配置时写的是仓库文件，运行时状态容易混进 git。
3. Dotbot 的 YAML 只表达链接，无法表达「这个文件复制、那个文件链接」，也无法按主机裁剪文件集合。

目标：改用 dotdrop，**逐文件声明 src/dst 映射**，默认 `nolink`（复制），仅对必须共享的配置保留链接。仓库现有目录布局不变。

## 现状盘点

### 当前 Dotbot 映射

`install.conf.yaml` 的 link 段共 26 条，全部是符号链接：

| 目标 | 源 | 类型 |
|---|---|---|
| `~/.bashrc` | `bash/bashrc` | 文件 |
| `~/.claude/CLAUDE.md` | `agents/CLAUDE.md` | 文件 |
| `~/.codex/AGENTS.md` | `agents/CODEX.md` | 文件 |
| `~/.config/atuin/` | `atuin` | 目录 |
| `~/.config/karabiner/` | `karabiner` | 目录 |
| `~/.config/ghostty/` | `ghostty` | 目录 |
| `~/.config/herdr/config.toml` | `herdr/config.toml` | 文件 |
| `~/.config/herdr/codex-usage.py` | `herdr/codex-usage.py` | 文件 |
| `~/.config/herdr/commandcode-usage.py` | `herdr/commandcode-usage.py` | 文件 |
| `~/.config/herdr/host-status.sh` | `herdr/host-status.sh` | 文件 |
| `~/.config/herdr/mac-power.py` | `herdr/mac-power.py` | 文件 |
| `~/.config/hunk/config.toml` | `hunk/config.toml` | 文件 |
| `~/.config/kitty/` | `kitty` | 目录 |
| `~/.config/lazygit/` | `lazygit` | 目录 |
| `~/.config/yazi/` | `yazi` | 目录 |
| `~/.gitconfig` | `git/gitconfig` | 文件 |
| `~/.hammerspoon` | `hammerspoon` | 目录（继承目标路径） |
| `~/.inputrc` | `bash/inputrc` | 文件 |
| `~/.profile` | `bash/profile` | 文件 |
| `~/.p10k.zsh` | `zsh/p10k.zsh` | 文件 |
| `~/.tmux` | `tmux` | 目录（继承目标路径） |
| `~/.tmux.conf` | `tmux/tmux.conf` | 文件 |
| `~/.vim` | `vim` | 目录（继承目标路径） |
| `~/.vimrc` | `vim/vimrc` | 文件 |
| `~/.zsh` | `zsh` | 目录（继承目标路径） |
| `~/.zshenv` / `~/.zprofile` / `~/.zshrc` | `zsh/zshenv` / `zsh/zprofile` / `zsh/zshrc` | 文件 |

shell 段还有 5 条命令：`touch ~/.hushlogin`、两条 submodule 更新、`git clean -fdx vim/pack/vendor/start/`、条件安装 herdr 插件。

### 必须排除的内容

这些路径不能进 dotdrop 的 `src`，否则 `install` 会用空目录覆盖家目录、`update` 会把运行时状态收进仓库：

| 路径 | 体积 | 原因 |
|---|---|---|
| `zsh/plugins/` | 10 个第三方插件 | `.gitignore` 忽略，`zsh/install_plugins.sh` 克隆 |
| `vim/pack/vendor/` | 11 个第三方插件 | `.gitignore` 忽略，`vim/install_plugins.sh` 克隆 |
| `tmux/plugins/` | tpm 及插件 | `.gitignore` 忽略，tpm 管理 |
| `lazygit/state.yml` | 运行时状态 | `.gitignore` 忽略，lazygit 写入 |
| `karabiner/karabiner.json` | 运行时生成 | `.gitignore` 忽略，Karabiner 写入 |
| `karabiner/automatic_backups/` | 自动备份 | `.gitignore` 忽略 |
| `zsh/hosts/*.secret*` | 私密配置 | `.gitignore` 忽略 |

### 需要判断的边界情况

- **`karabiner/`**：`karabiner.json` 被忽略但需要部署（`karabiner/assets/` 由 Karabiner 读取）。处理方式：单独一条 dotfile 只指向 `karabiner.json`，`karabiner/assets/` 另起一条，或在 `instignore` 里排除 `automatic_backups/`。
- **`yazi/`**：34 个文件全部被跟踪，可以整目录 `nolink`。但 `yazi/plugins/` 里混有自写插件（`git-diff-preview.yazi`）和第三方插件（`lazygit.yazi`、`chmod.yazi`），全部已跟踪，保持整目录复制。
- **`vim/` 和 `tmux/`、`zsh/`**：必须以「整目录链接或复制 + 忽略插件目录」处理。用 `litignore`/`instignore`/`upignore` 排除。
- **`herdr/`**：`herdr/config.toml` 是 GUI 会写的文件，用 `nolink`；`host-status.sh`、三个 `.py` 是脚本，用 `nolink` 并且需要保持可执行位。
- **`zsh/hosts/`**：`local_index.sh` 在缺少主机文件时会 `touch` 新建（`create_host_config`）。用 `nolink` 可写，用链接则新文件落在仓库里。建议 `nolink`。

## dotdrop 配置方案

### 目录布局

`dotpath` 设为仓库根目录，`src` 直接用现有路径，不动任何文件位置：

```yaml
config:
  dotpath: .
  link_dotfile_default: nolink   # 默认复制
  backup: true                   # 覆盖前留 .dotdropbak
  create: true
```

### 完整 config.yaml

```yaml
config:
  dotpath: .
  link_dotfile_default: nolink
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
  f_bashrc:
    src: bash/bashrc
    dst: ~/.bashrc
  f_profile:
    src: bash/profile
    dst: ~/.profile
  f_inputrc:
    src: bash/inputrc
    dst: ~/.inputrc
  f_claude_md:
    src: agents/CLAUDE.md
    dst: ~/.claude/CLAUDE.md
  f_codex_agents:
    src: agents/CODEX.md
    dst: ~/.codex/AGENTS.md
  f_gitconfig:
    src: git/gitconfig
    dst: ~/.gitconfig
  f_p10k:
    src: zsh/p10k.zsh
    dst: ~/.p10k.zsh
  f_zshenv:
    src: zsh/zshenv
    dst: ~/.zshenv
  f_zprofile:
    src: zsh/zprofile
    dst: ~/.zprofile
  f_zshrc:
    src: zsh/zshrc
    dst: ~/.zshrc
  d_zsh:
    src: zsh
    dst: ~/.zsh
  d_vim:
    src: vim
    dst: ~/.vim
  d_tmux:
    src: tmux
    dst: ~/.tmux
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
  d_atuin:
    src: atuin
    dst: ~/.config/atuin
  d_ghostty:
    src: ghostty
    dst: ~/.config/ghostty
  d_karabiner:
    src: karabiner
    dst: ~/.config/karabiner
  f_hunk:
    src: hunk/config.toml
    dst: ~/.config/hunk/config.toml
  f_herdr_config:
    src: herdr/config.toml
    dst: ~/.config/herdr/config.toml
  f_herdr_host_status:
    src: herdr/host-status.sh
    dst: ~/.config/herdr/host-status.sh
  f_herdr_codex_usage:
    src: herdr/codex-usage.py
    dst: ~/.config/herdr/codex-usage.py
  f_herdr_commandcode_usage:
    src: herdr/commandcode-usage.py
    dst: ~/.config/herdr/commandcode-usage.py
  f_herdr_mac_power:
    src: herdr/mac-power.py
    dst: ~/.config/herdr/mac-power.py
```

`d_zsh` 覆盖 `~/.zsh` 整目录，会和 `f_p10k` / `f_zshenv` / `f_zprofile` / `f_zshrc` 重复（这些文件本来就在 `zsh/` 里）。两个选择：

- 只保留 `d_zsh` 一条，`~/.zshrc` 等改由链接/复制目录内的文件承担：不可行，zsh 只找 `~/.zshrc`，不会找 `~/.zsh/zshrc`。
- 保留文件条目 + 目录条目，共用同一批源文件。dotdrop 允许同一 `src` 出现在多条 dotfile，但 install 同一文件两次会互相覆盖。**建议把目录条目换成显式文件列表**，或者给 `d_zsh` 加 `instignore` 排除顶层那几个文件。

待定项，见「待你决定的问题」第 1 条。

### 需要链接而非复制的条目

只有确实需要「改一处两边同时变」的文件才用 `link: absolute`。候选：

- `agents/CLAUDE.md`、`agents/CODEX.md`：多个 agent 工具读取，内容随时改，链接更省事。
- `hunk/config.toml`：如果 hunk 会写回。

其余全部 `nolink`。Herdr 的 `config.toml` 必须 `nolink`——这正是本次迁移的直接起因。

## 清理清单

### 要删除的

| 对象 | 处理 |
|---|---|
| `install.conf.yaml` | 删除，映射迁入 `config.yaml` |
| `install.conf.README.txt` | 删除，Dotbot 专用的操作说明 |
| `dotbot/` 子模块 | `git submodule deinit -f dotbot`、`git rm -f dotbot`、删 `.git/modules/dotbot`，并删 `.gitmodules` 里的 `submodule.dotbot.*` 四条 |
| `init_dotfiles.sh` | 删除。它是 Dotbot 仓库的配置生成器，全仓库无引用（`grep -rn init_dotfiles` 只命中自身） |
| `.idea/vcs.xml` 里的 dotbot 映射 | 该文件未被 git 跟踪，可删或手工编辑；不影响仓库 |
| `~/.dotfiles/vim/pack/vendor/start` 的三个 gitlink | 见「待你决定的问题」第 2 条 |

### 要改写的

| 对象 | 改动 |
|---|---|
| `install` | 改为调用 `dotdrop --cfg config.yaml install --profile <host>`；保留 `set -e`，保留 submodule 与插件安装逻辑 |
| `zsh/aliases.sh` 的 `dfu()` | 调用 `./install` 的行为不变，但提示语里的 `git pull --ff-only` 与重启 shell 要保留；如 `install` 语义变化（会覆盖家目录文件）需在函数里加确认 |
| `README.md` / `README-en.md` | 「基于 Dotbot 的一键安装」改为 dotdrop；「如果某些文件已存在，需要先删除」那段按 dotdrop 的 `backup: true` 行为重写 |
| `AGENTS.md` | 无需改，Changelog 要求保留 |
| `CHANGELOG.md` | 追加迁移条目 |
| `context.md`、`research.md` | 未被跟踪，不涉及 |
| `.gitmodules` | 删掉 dotbot 段；vim 三个段见第 2 条 |

### 要新增的

| 对象 | 用途 |
|---|---|
| `config.yaml` | dotdrop 配置 |
| `install` 增加 dotdrop 可用性检查 | 未安装时提示 `brew install dotdrop` |

## 迁移步骤

### 阶段 0：准备

1. 在本地和 macmini 各跑一次「家目录有哪些文件仓库里没有」的清点，确认没有只存在于家目录的配置。重点检查 `zsh/hosts/`、`karabiner/`、`lazygit/`。
2. `brew install dotdrop`（本地与所有远程机器）。dotdrop 的依赖是 `certifi`、`libmagic`、`python@3.14`。
3. 确认所有机器的仓库都是干净工作树。

### 阶段 1：建立配置（不动现有链接）

1. 新增 `config.yaml`，映射照抄上表。
2. 跑 `dotdrop compare -c config.yaml` 看差异，确认 src/dst 解析正确。
3. 跑 `dotdrop install --dry -c config.yaml` 预演，确认不会碰 `plugins/`、`pack/vendor/`。

### 阶段 2：本机切换

1. 逐个把现有符号链接换成普通文件：
   ```sh
   for f in ~/.bashrc ~/.profile ~/.inputrc ~/.gitconfig ~/.p10k.zsh ~/.zshenv ~/.zprofile ~/.zshrc; do
     [ -L "$f" ] && rm -f "$f"
   done
   for d in ~/.zsh ~/.vim ~/.tmux ~/.hammerspoon ~/.config/yazi ~/.config/kitty \
            ~/.config/lazygit ~/.config/atuin ~/.config/ghostty ~/.config/karabiner; do
     [ -L "$d" ] && rm -f "$d"
   done
   ```
   注意：删链接不会删仓库源文件，安全。
2. 跑 `dotdrop install -c config.yaml`，生成普通文件。
3. 逐个功能验证：新开 zsh（插件、缩写、别名、prompt）、vim（插件加载）、tmux（tpm、popup）、hammerspoon 重载、yazi、kitty、lazygit、atuin、Herdr 设置页底部不再显示 Unavailable。
4. 验证插件目录仍在（`~/.zsh/plugins/`、`~/.vim/pack/vendor/start/`、`~/.tmux/plugins/` 未被清空）。

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
3. 执行阶段 2 第 1 步的链接清理 loop——**这一步是必需的**，否则 `dotdrop install` 会与残留链接冲突。
4. `dotdrop install -c config.yaml`。
5. `dfu` 验证：`git pull --ff-only` + `./install` + `exec zsh` 全程无报错。

### 阶段 5：回滚方案

迁移前打 tag：`git tag pre-dotdrop`。出问题时：

```sh
git checkout pre-dotdrop
rm -f 相关普通文件
./install   # 旧 Dotbot 脚本仍可用
```

阶段 3 删除 Dotbot 之前，回滚只要 `git checkout`；删除之后回滚需要 `git revert` 迁移提交。

## 风险

| 风险 | 影响 | 缓解 |
|---|---|---|
| `install` 语义从「建链接」变为「覆盖文件」 | 家目录被仓库版本覆盖，丢失未提交改动 | `backup: true` 留 `.dotdropbak`；迁移前先 `dotdrop compare`；阶段 0 清点 |
| `d_zsh` 等目录条目与 `f_zshrc` 等文件条目重叠 | 同一文件被部署两次，互相覆盖 | 见待决问题第 1 条 |
| 整目录 `nolink` 复制插件目录 | 复制上万个文件，slow 且占空间 | `instignore` 排除 `*/plugins/*`、`*/pack/vendor/*` |
| 权限位丢失 | `host-status.sh`、`codex-usage.py` 等失去可执行位 | `force_chmod: true`；或在 config 里逐个写 `chmod: 755` |
| 远程机器忘记清理旧链接 | `dotdrop install` 报冲突或行为异常 | `install` 脚本内置链接清理 loop |
| 运行时文件被 `update` 收进仓库 | `karabiner.json`、`state.yml` 进 git | `upignore` 显式排除 |
| dotdrop 只在 macOS/Linux 可用 | 无 Windows 支持 | 本仓库本来就没有 Windows 目标 |
| Herdr 改回链接后 GUI 又报 Unavailable | 迁移前 GPUI 仍不可用 | 迁移完成即恢复；迁移期间可临时不改动该文件 |

## 验证方式

每阶段完成后手工验证，不写自动化测试：

- `dotdrop compare -c config.yaml` 无输出：src 与 dst 一致。
- `dotdrop install --dry -c config.yaml` 不触碰插件目录。
- 阶段 2 第 3 步的功能清单逐项通过。
- `git status` 在 `update` 之后只显示预期改动。
- 远程机器 `dfu` 后 `exec zsh` 进入新 shell 无报错。

## 待你决定的问题

1. **`d_zsh` 与 `f_zshrc` 等重叠怎么处理。**
   选项 A：只保留目录条目，并在 `~/.zshrc` 位置用 dotdrop 的 `link` 指向目录内文件（不推荐，符号链接问题回归）。
   选项 B（推荐）：不设 `d_zsh` 目录条目，把 `zsh/` 顶层需要的文件逐个列成 `f_*`，`zsh/` 下的子目录（`aliases/`、`hosts/`、`custom-plugins/`）各起一条目录 dotfile。`~/.zsh` 本身不必存在——`zsh/zshrc` 里 `source ~/.zsh/plugins/...` 的引用需要改成 `~/.dotfiles/zsh/plugins/...`，但那样又依赖仓库路径。
   选项 C：保留 `d_zsh` 整目录复制，删掉 `~/.zshrc` 等四条文件条目，改为在 `~/.zsh` 里额外放 zsh 能直接找到的文件——不可行，zsh 只读 `$HOME/.zshrc`。
   **这一条决定 `zsh/` 部分的配置形状，需要你先定。**

2. **vim 的三个 gitlink 是否一并清理。**
   `.gitmodules` 里有 `vim/pack/vendor/start/nerdtree`、`vim-tmux-clipboard`、`vim-tmux-focus-events` 三条，但 `vim/pack/vendor/start` 被 `.gitignore` 忽略，git 索引里**没有**这三个 gitlink（只有 `dotbot` 一个）。也就是说这三条 `.gitmodules` 记录是历史残留，对应目录由 `vim/install_plugins.sh` 克隆。
   建议：随本次迁移一并删除这三条 `.gitmodules` 记录，并删除对应的 `.git/modules/vim/...` 缓存目录。要你确认。

3. **是否给整目录条目改用链接而非复制。**
   `~/.vim`（521 文件）、`~/.zsh`（1207 文件，含插件）、`~/.tmux`（484 文件，含插件）复制开销明显。如果这些目录复制后没有 GUI 写入问题，可以用 `link: absolute` 换回链接，只有 Herdr 那类必须复制的走 `nolink`。
   建议：`zsh/`、`vim/`、`tmux/` 用链接（忽略插件目录后复制量很小，链接更省），Herdr 的 `config.toml` 用 `nolink`。要你确认。

4. **新仓库还是当前仓库。**
   本方案假设在当前仓库就地迁移，理由是仓库内 `~/.dotfiles/...` 路径引用有二十余处（`zsh/zshrc`、`aliases.sh`、`local_index.sh`、`brew/*.sh`、`dfu`），换仓库要全部改写并逐机重配。若你仍想开新仓库，本方案的映射表可直接复用，但需要额外一节说明路径改写。

## 附：Dotbot 与 dotdrop 行为对照

| 场景 | Dotbot（现在） | dotdrop（迁移后） |
|---|---|---|
| 部署文件 | 建符号链接 | 默认复制，可逐条选链接 |
| 改仓库文件后 | 立即生效（链接） | 需要 `dotdrop install` |
| 改家目录文件后 | 改的就是仓库文件 | 需要 `dotdrop update` |
| 家目录已有文件 | 报错要求手删 | `backup: true` 留 `.dotdropbak` 后覆盖 |
| 按主机裁剪 | 无 | profiles |
| 忽略子目录 | 无 | `instignore` / `upignore` / `cmpignore` |
| 加密 | 无 | `trans_install` / `trans_update` |
| 模板 | 无 | 支持 |
| 权限 | 继承源文件 | `chmod` 条目或 `force_chmod` |
| 命令 | `./install` | `dotdrop install` / `update` / `compare` |
