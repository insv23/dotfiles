-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.winbar = "%=%m %f"

-- 使用系统剪贴板
-- 远程服务器中 tmux copy 后已经能自动发送到本地剪贴板中
-- 让 nvim 复制内容自动落入系统剪贴板中，这样就能自动发送到本地剪贴板
vim.opt.clipboard = "unnamedplus"
