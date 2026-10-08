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
