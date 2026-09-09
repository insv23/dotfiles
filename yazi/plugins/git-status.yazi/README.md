# git-status.yazi

显示 Git 工作区中现有文件的文字状态，并将深层文件的状态传播到所有父目录。

状态标记：

- `M`：已修改
- `A`：新增或暂存新增
- `?`：未跟踪
- `R`：重命名
- `U`：冲突

删除文件不显示。Yazi 文件列表本身也不会显示已经删除的文件，因此删除状态不会创建目录占位。

## Setup

在 `init.lua` 中加载：

```lua
require("git-status"):setup()
```

在 `yazi.toml` 中注册 fetcher：

```toml
[plugin]
prepend_fetchers = [
    { id = "git-status", url = "*", run = "git-status", group = "git-status" },
    { id = "git-status", url = "*/", run = "git-status", group = "git-status" },
]
```

插件使用当前仓库根目录执行 `git status --porcelain=v1 -z`，适配包含空格、中文和换行的路径。
