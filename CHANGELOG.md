# Changelog

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