# git-diff-preview.yazi

在 Yazi 右侧预览区显示带颜色的完整 Git diff。

- 删除块显示为红色，新增块显示为绿色。
- 隐藏 Git 文件头、哈希和 hunk 行号，只保留文件内容及其变动块。
- 保留完整上下文，便于快速查看整个文件的变动。
- staged、unstaged 变动统一与 `HEAD` 比较。
- 未追踪文件显示为完整新增内容。
- 没有 Git 变动时回退到 Yazi 默认代码预览。
- 目录继续使用 `eza-preview`。

插件不启动交互式 pager，因此不会接管 Yazi 的预览区滚动和焦点。
