-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.winbar = "%=%m %f"

-- 2025-06-10 最终结论: 不要再试图同步 vim 剪贴板了，OSC52 全是天坑
-- 正经编辑还是用 vscode
-- 简单复制使用 cat 然后选中
vim.opt.clipboard = ""           -- 这个就叫无名寄存器
-- vim.opt.clipboard = "unnamedplus"   -- 默认使用 + 寄存器（通常是 Ctrl+C 复制，Ctrl+V 粘贴）。
-- vim.opt.clipboard = "unnamed"    -- 默认使用 * 寄存器（通常是鼠标中键粘贴，在 Windows 和 macOS 上通常等同于系统剪贴板）。
--
-- 冗长的试错总结:(已经解决了 Kitty → SSH → tmux → Neovim 远程nvim 拷贝不会到本地剪贴板的问题)
-- ① 推荐默认使用无名寄存器。
-- 每个 nvim 维持自己的无名寄存器。即多个 tmux window 的不同 nvim 无法共享无名寄存器，1 号寄存器，还有自定义的寄存器
-- 不用 unnamedplus 和 unnamed 的原因是它们可能会导致 OSC52 相关错误。(终端模拟器、tmux、nvim 这些东西串在一起搞不清是哪个地方挂了)
--
-- ② 对我来说，最重要的是"能拷贝远程服务器中的内容到本地"，(本地粘贴到远程使用 cmd v 就能成功)
-- 而 kitty 中 tmux 内使用 nvim, 没有方法将远程内容传到本地。
-- 如果是 kitty 内直接 nvim, 则能通过 "+y 传到本地，但 远程服务 非常容易断，不用 tmux 是几乎不可能。
-- 如果 vscode 中 tmux 内用 nvim，则 "+y 可以传到本地。
--
-- ③ 尽量多使用 vscode
-- 使用 ssh 直接连接服务器经常会自己断掉，vscode 要稳定很多。
-- 在 vscode 内使用 tmux 来让某个程序能"持久运行"
--
-- ④ 少折腾命令行内的内容，完全是在不停踩坑。更烦人的是昨天能跑，今天就跑不了。
--
-- 问题② 解决记录
-- 🫣2025-02-27
-- Claude 3.7 一发入魂
-- 提示我需要在 tmux.conf 中配置下面两列:
-- set -g allow-passthrough on
-- set -s set-clipboard on
-- 🔥2025-03-22
-- 远程 Linux 机器上需要有 xclip 和 xsel
-- sudo apt update && sudo apt install -y xsel xclip

-- 禁用 LazyVim 的保存时自动格式化功能
-- 虽然好像使用的 conform 进行格式化，但也只是 `空格cf` 这个生效
-- 在 conform.lua 中禁止自动格式化没用
vim.g.autoformat = false
