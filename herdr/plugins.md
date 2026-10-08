# Herdr 插件清单

Herdr 的插件清单只存在 `~/.config/herdr/plugins.json`，在仓库外，新设备无从得知装过什么。
这份文件只做记录，`install` 不碰插件。换设备时把这里的内容交给 AI，按下面的说明逐个安装。

安装命令统一是：

```bash
herdr plugin install <owner>/<repo> --yes
```

插件装完由 `herdr` 自己编译（`cargo build --release`），所以目标机器需要可用的 Rust 工具链。

## llmxby/herdr-focus-notify

macOS 上可点击的通知。agent 变成 `blocked` 或 `done`、且你不是正在看那个 pane 时发通知，
点击后先把终端拉到前台，再跑 `herdr agent focus <pane_id>` 跳到那个 pane。
Herdr 自带的通知只能唤回窗口，进不到具体 pane，这个插件补的正是这一段。

依赖 [alerter](https://github.com/vjeantet/alerter) 作为通知后端（能上报点击事件），
macOS 需 `brew install vjeantet/tap/alerter`；该条目已在 `brew/brew-mac.txt` 中。

配置写在 `~/.config/herdr/plugins/config/herdr-focus-notify/.env`，该目录不进仓库，内容：

```env
HERDR_FOCUS_NOTIFY_NOTIFIER=/opt/homebrew/bin/alerter
HERDR_FOCUS_NOTIFY_ACTIVATE_APP=kitty
HERDR_FOCUS_NOTIFY_STATUSES=blocked,done
HERDR_FOCUS_NOTIFY_TIMEOUT=3600
```

`ACTIVATE_APP` 决定点击通知时拉起哪个终端，换终端时要改。配合使用时，
`config.toml` 的 `[ui.toast] delivery` 应为 `herdr`，否则同一次状态变化会收到两条通知。

插件还注册了 `focus-latest` action，可用全局快捷键调用：

```bash
herdr plugin action invoke focus-latest --plugin herdr-focus-notify
```

## osamahbeig/herdr-pane-mover

把当前 pane 挪到别处：移动到其他 tab 或新 tab、其他 workspace 或新 workspace、
重新切分，或与另一个 pane 交换位置。按下后弹出一个 overlay 菜单来选。

安装后由 `config.toml` 中的自定义键位调用：

```toml
[[keys.command]]
key = "prefix+m"
type = "plugin_action"
command = "osamahbeig.pane-mover.open"
description = "move this pane"
```

无需额外配置或外部依赖。

## kadaliao/herdr-plugins (space-index)

在左侧 Spaces 侧边栏的每个 space 前面显示它的编号，也就是 `switch_workspace = "alt+1..9"`
真正的目标位置。Herdr 的 `[ui.sidebar.spaces] rows` 只认 `state_icon`、`state_text`、
`workspace`、`branch`、`git_status` 和自定义 `$name`，没有内置的编号 token，按快捷键前只能自己数行。

插件读 `herdr workspace list` 已返回的 `number` 字段，用 `herdr workspace report-metadata`
写回成 workspace metadata 的 `idx` token，再由侧边栏的 `"$idx"` 渲染。这个仓库是单仓库多插件，
安装要带子目录，插件 id 仍是 `kadaliao.space-index`：

```bash
herdr plugin install kadaliao/herdr-plugins/space-index --yes
herdr server reload-config
herdr plugin action invoke kadaliao.space-index.refresh
```

`config.toml` 里加上渲染它的那一段（`rows` 是整段替换默认布局，所以 `branch` / `git_status`
要写出来）。`refresh` 不必绑键，编号会在 `workspace.created`、`workspace.closed`、
`workspace.moved`、`workspace.reordered` 以及服务器启动时自己重报，启动那次是因为 metadata
token 只存在内存里、重启不恢复：

```toml
[ui.sidebar.spaces]
row_gap = 0
rows = [
  ["$idx", "state_icon", "workspace"],
  ["branch", "git_status"],
]
```

依赖 `python3`（插件命令是 argv 数组，不走 shell）与 Herdr ≥ 0.9.0。只影响展开的桌面侧边栏，
收起的窄栏和移动端布局是 Herdr 自己的紧凑版，本来就带编号。编号是事件驱动重新上报的展示用
metadata，最多滞后一个事件；超过 9 个 space 仍会渲染，但只有 1–9 有键位。

同仓库另有 `kadaliao/herdr-plugins/agent-index`（给 agent 面板编号，配 `focus_agent`）与
`kadaliao/herdr-plugins/status-bar`，未装。
