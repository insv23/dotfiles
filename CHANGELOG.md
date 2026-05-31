# Changelog

## 2026-05-31

### Raycast

- **新增 Excalidraw Live Room 脚本**：添加 Raycast Script Command，一键生成并打开新的 Excalidraw live collaboration 房间链接，省去手动点击 Share
- **移除 Raycast 脚本 Node 依赖**：将 Excalidraw Live Room 的随机链接生成改为使用系统 Python，避免 Raycast 环境加载不到 nvm Node
- **补充 Raycast 使用文档**：新增 Raycast README，记录 Script Commands 目录添加、重载、运行和快捷键绑定方式，方便后续维护脚本

### Yazi

- **新增 lazygit 插件**：通过 `ya pkg add Lil-Dank/lazygit` 安装 `lazygit.yazi`，并绑定 `g i` 在当前 Git 仓库中打开 lazygit

### Zsh

- **保留 vv 调用目录**：将 `vv` 的草稿目录切换限制在子 shell 中，保持 Vim 内默认保存到 `~/.vimdrafts`，退出后回到原工作目录
- **新增 DeepSeek Pi 缩写**：添加 `pdf` 与 `pdp`，分别用于快速以 DeepSeek Flash 和 Pro 模型启动 pi，方便低成本处理轻量任务
- **允许 Pi vision proxy 读取 home 目录**：在 `zsh/hosts/mba.local.zshrc` 中添加 `PI_VISION_PROXY_ALLOW_HOME=1`，只在本地机器生效，不泄漏到远程主机

## 2026-05-30

### Zsh

- **迁移常用别名到 abbr**：将 Docker、Tmux、Zellij、Brew、Python、Git 辅助命令等短命令从 alias 迁移到 `zsh/abbreviations`，让输入后展开为完整命令并保留更清晰的历史记录
- **延迟加载 NVM**：将 NVM 初始化改为 lazy-load，启动时仅把默认 Node 版本加入 PATH，首次调用 `nvm` 或进入含 `.nvmrc` 的目录时再加载完整 NVM，降低新建终端冷启动耗时
- **减少冷启动外部命令**：将 Homebrew 环境初始化改为静态变量，并缓存 Carapace zsh 初始化脚本，减少新建终端时的外部命令 fork 开销
- **补充 Homebrew 初始化回滚说明**：在 `zshenv` 中完整保留 `brew shellenv` 原始代码块注释，说明原始写法的作用、启动影响、改用静态变量的性能原因和出现兼容问题时的恢复方式

## 2026-05-22

### Yazi

- **恢复 what-size 快捷键**：重新安装 `what-size` 插件并将 `,d` 绑定为计算当前选中项或当前目录大小，替换原先的临时排序方案

## 2026-05-21

### Zsh

- **优化补全初始化缓存**：为 `compinit` 增加 `~/.zcompdump` 新鲜度判断，24 小时内使用 `compinit -C` 快路径，减少新建终端首个 tab 的补全扫描和缓存重建耗时
- **清理重复 Bun 补全**：删除全局 `zshrc` 末尾重复加载的 Bun completion，保留主机级 `mba.local.zshrc` 中的 Bun 配置，避免重复 source
- **新增自动追加警戒线**：在 `zshrc` 底部加入系统自动追加区域注释，约定自定义功能放在线上方，便于识别安装器或 CLI 后续自动写入的内容

## 2026-05-19

### Tmux

- **优化鼠标复制停留位置**：禁用 tmux-yank 的默认鼠标拖选复制绑定，改用 `copy-pipe-no-clear` 将选区复制到系统剪贴板并保留 copy mode 位置，避免复制后自动跳回底部
- **明确上下分屏方向**：将 `prefix + -` 的分屏命令显式加上 `-v`，确保快捷键语义固定为上下分屏，减少受默认行为或布局状态影响的歧义
- **调整 Yazi 启动方式**：将 `prefix + e` 从 tmux popup 改为 `new-window -S` 复用当前 session 中名为 `yazi` 的独立 window；已存在时直接跳转，未存在时在当前目录创建，规避 yazi 与 tmux popup 的终端探测和图片协议兼容性问题
- **调整 Lazygit 启动方式**：将 `prefix + g` 改为 `new-window -S` 复用当前 session 中名为 `lazygit` 的独立 window；已存在时直接跳转，未存在时在当前目录创建，避免重复打开多个 lazygit
- **重整工具窗口说明**：将原 `Floating Windows` 注释扩展为 `Tool Windows / Popups`，区分短时 popup 与复用式工具 window，并记录 yazi 避开 tmux popup 兼容性问题、lazygit 保留目录上下文的原因

## 2026-05-18

### Tmux

- **新增持久化浮动终端**：将 `prefix + p` 绑定为按当前 session 与 window ID 隔离的持久 popup，关闭后进程继续运行，再次按 `prefix + p` 可关闭 popup 视图，方便快速召回 pi、Codex 或 Claude Code
- **优化鼠标滚轮速度**：覆盖 tmux 默认滚轮行为，将每格滚动调整为 2 行，让鼠标滚动历史记录更接近终端原生手感
- **调整左右分屏快捷键**：将左右分屏从 `prefix + |` 改为 `prefix + v`，降低按键复杂度；copy mode 中的 `v` 选择文本保持不变

## 2026-05-17

### Vim

- **新增 JSON timed_words 折叠**：新增 `:FoldTimedWords` 与 `<Leader>zt`，可一键折叠当前 JSON 文件中的 `"timed_words"` 字段数组；同时将 `<Leader>za`、`<Leader>zR`、`<Leader>zM` 纳入 which-key 折叠提示，方便记忆常用折叠操作
- **新增当前行无换行复制**：将 `Y` 映射为 `0y$`，用于复制当前行内容且不包含行尾换行符，保留 `yy` 的整行复制默认行为

## 2026-05-15

### Vim

- **优化括号匹配高亮**：为 `MatchParen` 设置暗灰蓝背景和暖色前景，降低默认青绿色块状高亮的遮挡感，提升暗色主题下的可读性

## 2026-05-14

### Pi

- **新增 Agent Browser 文档**：新增 `docs/agent-browser.md`，记录上游 `agent-browser` 与 Pi 扩展 `pi-agent-browser-native` 的安装、检查、基础调用和常见使用注意事项
- **简化完成通知扩展**：将 `pi/extensions/notify.ts` 调整为仅在 agent 结束时发送 `Task complete` 通知并播放 `pi_output_end.mp3`，移除基于关键词的等待确认判断，避免误触发
- **纳入全局指令管理**：新增 `pi/AGENTS.md`，并在 `install.conf.yaml` 注册 `~/.pi/agent/AGENTS.md → ./pi/AGENTS.md` symlink，让 pi 的全局上下文指令也由 dotfiles 统一管理
- **清理重复全局指令**：删除散落在 home 目录的 `~/AGENTS.md`，统一改由 `~/.pi/agent/AGENTS.md` 提供 pi 全局上下文，避免从 home 父目录重复加载

### Codex

- **纳入全局指令管理**：新增 `codex/AGENTS.md`，并在 `install.conf.yaml` 注册 `~/.codex/AGENTS.md → ./codex/AGENTS.md` symlink，让 Codex 全局行为规则由 dotfiles 统一管理

## 2026-05-13

### Pi

- **editorPaddingX 设为 1**：增加输入编辑器水平内边距，文字不再贴边框
- **纳入 dotfiles 管理**：创建 `~/.dotfiles/pi/extensions/`，在 `install.conf.yaml` 注册 `~/.pi/agent/extensions/ → ./pi/extensions` symlink，后续所有 pi 扩展统一在此 git 管理
- **启用任务完成通知扩展**：将 pi 官方 `notify.ts` 扩展安装到 `~/.pi/agent/extensions/`，agent 停止后根据末尾文本智能区分音效：检测到确认等待模式（请确认/要继续吗等）播放 `pi_wait_input.mp3`，否则播放 `pi_output_end.mp3`；同时发送终端原生通知，支持 Ghostty / iTerm2 / WezTerm / Kitty / Windows Terminal
- **新增模型思考强度自动同步扩展**：添加 `pi/extensions/model-thinking-sync.ts`，将 `openai-codex/gpt-5.5` 自动切换为 `medium`、`deepseek/deepseek-v4-pro` 自动切换为 `high`；在启动/恢复会话和切换模型时都会重新应用，减少手动调整 thinking level

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
