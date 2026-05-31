# Raycast

Raycast Script Commands 管理目录。

## Script Commands

当前脚本目录：

```text
/Users/tony/.dotfiles/Raycast/scripts
```

在 Raycast 中添加目录：

1. 打开 Raycast Settings
2. 进入 `Extensions`
3. 点击右上角 `+`
4. 选择 `Add Script Directory`
5. 选择目录：

```text
/Users/tony/.dotfiles/Raycast/scripts
```

6. 运行 Raycast 命令：

```text
Reload Script Directories
```

## 当前脚本

### Excalidraw Live Room

命令名：

```text
Excalidraw Live Room
```

用途：生成并打开新的 Excalidraw live collaboration room。

脚本路径：

```text
Raycast/scripts/excalidraw-live-room.sh
```

运行方式：

1. 打开 Raycast
2. 搜索 `Excalidraw Live Room`
3. 回车运行

绑定快捷键：

1. Raycast 搜索 `Excalidraw Live Room`
2. 按 `Cmd + K`
3. 选择 `Configure Command`
4. 选择 `Record Hotkey`
5. 输入目标快捷键

## 维护

新增脚本后需要设置可执行权限：

```bash
chmod +x Raycast/scripts/<script-name>.sh
```

脚本应包含 Raycast metadata，例如：

```bash
# @raycast.schemaVersion 1
# @raycast.title Command Title
# @raycast.mode silent
# @raycast.packageName Package Name
```

Raycast 运行环境的 `PATH` 较短。脚本里调用外部命令时，优先使用绝对路径，例如 `/usr/bin/python3`。
