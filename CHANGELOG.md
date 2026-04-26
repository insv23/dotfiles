# Changelog

## 2026-04-26

### Vim

- **stargate 搜索字符数调整**：将 `s` 键映射的 `stargate#OKvim(2)` 改为 `stargate#OKvim(1)`，按一个字母即可触发搜索跳转，减少一次按键
- **d/D 删除不污染剪贴板**：为 `d`/`D` 新增黑洞寄存器映射 `"_d`/`"_D`（normal + visual），与已有的 `c`/`C` 行为一致，删除的文本不会覆盖系统剪贴板
- **新增 `cie` 映射**：`:%d_<CR>i` 清空整个文件并进入插入模式（送入黑洞寄存器），与已有的 `yie`（复制全文件）、`die`（剪切全文件）形成完整的 `ie` 三件套
- **修复 `yie`/`die`/`cie` 映射的行尾注释被当作 RHS 执行的 bug**：在 `:nnoremap` 命令中 `"` 不会被识别为注释符，行尾的所有内容（含 `"` 及中文注释）均被当作映射的 `{rhs}` 的一部分实际执行，现已将注释移至行首独立一行

## 2026-04-24

### 项目规范

- **新增 CLAUDE.md**：在仓库根目录创建项目级 Claude 指令文件，要求每次改动后必须在 `CHANGELOG.md` 中追加对应条目，格式遵循现有日期/主题/要点风格

### zsh 目录整理

- **删除**：`aliases/ffmpeg.sh`、`aliases/noad.py`、`aliases/rm_media.py`（不再需要）
- **迁移**：`zsh/ssh.example.config` → 新建顶层 `ssh/config.example`，SSH 模板与 zsh 目录解耦
- **扩展名统一**：`fzf.zshrc` → `fzf.zsh`、`nvm.zshrc` → `nvm.zsh`（与 `zle.zsh`、`p10k.zsh` 保持一致）
- **`aliases/` 文件重命名**：统一扩展名为 `.zsh`，并优化部分文件名（`file_dir` → `files`、`bark_notify` → `bark`、`paste` → `clipboard`、`run_log` → `log`、`code-remote` → `vscode-remote`、`claude-code` → `claude`）
- **`aliases.sh`**：更新所有 source 路径，补充原缺失的 `claude.zsh` 加载项

### zsh 目录文件注释

- 为 `zsh/` 目录下所有文件（含 `aliases/`、`hosts/`、`custom-plugins/`）的顶部添加中文说明注释，共 32 个文件

### 文档与脚本修正

- **`setup.zsh`**：修正 tmux 步骤引用的脚本路径（`install_plugins.sh` → `install_tpm.sh`）
- **`README.md` / `README-en.md`**：全面校对并同步为与代码库一致的状态
  - 移除已废弃的 Neovim/LazyVim 功能描述
  - 安装步骤改为使用 `./setup.zsh` 交互式向导
  - 更新目录结构（新增 `bash/`、`git/` 等，移除 `nvim/`）
  - 修正终端工具描述（eza/bat/zoxide/fd 均非命令替换别名）
  - 修正 `dfu` 说明（快进同步，非强制覆盖）
  - 英文版：修复语言切换链接、补充缺失的 `su` 步骤与手动安装指引、修正示例用户名

### 根目录配置文件整理

- **新增 `bash/` 目录**：将 `bashrc`、`profile`、`inputrc` 从根目录迁入
- **新增 `git/` 目录**：将 `gitconfig`、`gitignore_global` 从根目录迁入
- **归位现有子目录**：`tmux.conf` → `tmux/`，`vimrc` → `vim/`，`zshrc` + `p10k.zsh` → `zsh/`
- **更新 `install.conf.yaml`**：所有隐式链接条目改为显式路径，指向各自新位置
- **更新 `gitconfig`**：`excludesfile` 路径同步修正为 `~/.dotfiles/git/gitignore_global`

### 废弃配置归档

- **新增 `.deprecated/` 目录**：将不再使用的配置统一归档至此
- **迁移目录**：`aider`、`ghostty`、`keyboard`、`kaku`、`nvim`、`zellij` 均移入 `.deprecated/`
- **清理 `install.conf.yaml`**：移除 `ghostty`、`zellij` 的活跃链接条目，删除 `aider`、`nvim` 的注释残留行

## 2025-12-28

### Zsh 缩写管理增强
- **新增插件**：
  - `zsh-abbr`：Fish shell 风格的缩写管理工具
  - `zsh-autosuggestions-abbreviations-strategy`：让 autosuggestions 能够建议缩写
- **缩写配置**：
  - 缩写文件统一管理在 `~/.dotfiles/zsh/abbreviations`
  - 配置建议策略：优先建议缩写，然后是历史命令
  - 缩写会在输入空格后自动展开为完整命令，便于学习和查看
- **Alias 迁移**：
  - 将简单的命令别名转换为 abbr（如 `pingg`、`dsize` 等）
  - 保留修改默认行为的 alias（如 `cp -i`、`mv -i`）
  - 保留全局别名（如 `C`、`P`）和函数
- **新增缩写**：
  - Git 操作：32 个常用 git 缩写（gst, gco, gcm 等）
  - 网络工具：ping 各大 DNS、查看 IP、proxychains
  - 文件管理：目录导航、文件大小排序等

## 2025-12-16

### Yazi 配置重构
- **简化文件打开逻辑**：移除了复杂的 smart/code/term_edit opener 配置
- **界面调整**：隐藏父目录列，改用 0,1,1 布局比例
- **新增插件**：
  - `smart-enter`：Enter 键智能行为（目录进入，文件打开）
  - `chmod`：可视化修改文件权限（快捷键 `cm`）
  - `eza-preview`：使用 eza 预览目录内容
  - `git`：在文件列表中显示 Git 状态（修改、新增、删除等）
- **编辑器切换**：默认 opener 改为 Zed

## 2025-11-30

- 不再使用 nvim
- 不再使用 micro (ctrl q 快捷键在 Cursor/VS Code 终端中不好使)，编辑器现在只 vim

## 2025-11-17

- zsh 编辑命令使用 vim (因为 micro 在 vscode/Cursor 终端中 ctrl q 可能已经被占用，而且 micrio 编辑命令不方便)

## 2025-11-01

- 将默认编辑器换为 micro


## 2025-11-02

- kitty 默认配置文件直接打开(cmd ,)使用 micro