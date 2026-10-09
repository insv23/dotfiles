# Herdr 插件清单

Herdr 的插件清单只存在 `~/.config/herdr/plugins.json`，在仓库外，新设备无从得知装过什么。
这份文件只做记录，`install` 不碰插件。换设备时把这里的内容交给 AI，按下面的说明逐个安装。

安装命令统一是：

```bash
herdr plugin install <owner>/<repo> --yes
```

插件装完由 `herdr` 自己编译（`cargo build --release`），所以目标机器需要可用的 Rust 工具链。

## herdr-notify-focus（自写）

macOS 上可点击的通知。agent 变成 `blocked`、`done` 或 `idle`、且你不是正在看那个 pane 时发通知，
点击后先激活终端（终端不是写死的：插件从 herdr 客户端进程的祖先链里找它所在的 .app，
拿 bundle id `open -b` 拉到前台，可用 `HERDR_NOTIFY_TERMINAL_BUNDLE` 强制指定），
再跑 `herdr agent focus <pane_id>` 跳到那个 pane。
Herdr 自带的通知只能唤回窗口，进不到具体 pane，这个插件补的正是这一段。

只看三种状态，因为 Herdr 的 `idle` 与 `done` 是同一个「空闲、等你输入」状态的两个名字：
那个 tab 被你看过就叫 `idle`，没看过才叫 `done`。只认 `done` 会漏掉大半情况——实测一轮结束时
常常只收到 `idle`。发不发的判断只在一件事上：你是不是正在看那个 pane（前台是这个终端、且 Herdr
聚焦的也是它，就不发）。

代码在 `~/code/herdr-plugins/herdr-notify-focus/`：`herdr-plugin.toml` 加 `plugin.js`（Node，无编译）。
不是从 GitHub 装的，换设备要把这个目录一起带过去，然后：

```bash
herdr plugin link ~/code/herdr-plugins/herdr-notify-focus
```

依赖 [alerter](https://github.com/vjeantet/alerter) 作为通知后端（能上报点击事件），
macOS 需 `brew install vjeantet/tap/alerter`；该条目已在 `brew/brew-mac.txt` 中。
插件零配置：终端从 herdr 客户端进程的祖先链自动探测（kitty、Ghostty 换着用都行，
多终端同时开也都认），换终端不需要改任何东西。

`config.toml` 的 `[ui.toast] delivery` 保持 `herdr`，只留应用内 toast；设成 `terminal` 或 `system`
会和插件的桌面通知重复。

### 为什么不用社区的 herdr-focus-notify

先后试过 `llmxby/herdr-focus-notify`（`yankewei/herdr-focus-notify` 的 fork，停在 0.3.6）
与上游 0.8.0，都不合用：

- 上游 0.8.0 为了零配置，用 `lsappinfo info -only bundleID <ASN>` 取前台 app。macOS 14.6 上
  `lsappinfo info` 只认 `-app` / `-pid` 寻址，传 ASN 没有任何输出；取不到前台 app 就不写终端
  绑定，点击通知因此什么都不做（`focus_pane` 在缺绑定处直接返回）。
- 两者的横幅图标都靠 alerter 的 `--app-icon`，它走 NSUserNotification 的私有键 `_identityImage`，
macOS 14 上被忽略。冒充终端身份也发不出可见通知（实测同一套参数只换 `--sender`：默认
Terminal 身份正常超时返回，`net.kovidgoyal.kitty` 和换到 Ghostty 后重测的
`com.mitchellh.ghostty` 都是 alerter 挂起不退、横幅不出现），只有 Terminal 身份能正常投递，
  所以图标固定是 Terminal 的。

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
