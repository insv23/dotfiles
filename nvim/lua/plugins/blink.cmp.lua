return {
  "saghen/blink.cmp",
  -- 可选：提供代码片段源
  dependencies = "rafamadriz/friendly-snippets",

  -- 使用发布标签下载预构建二进制文件
  version = "*",
  -- 或者从源代码构建（需要 nightly rust）
  -- build = 'cargo build --release',

  opts = {
    -- 键盘映射预设：
    -- 'super-tab': 类似 VSCode 的映射（Tab 或 <c-y> 接受，方向键导航）
    keymap = { preset = "super-tab" },

    appearance = {
      -- 使用 nvim-cmp 的高亮组作为回退
      use_nvim_cmp_as_default = true,
      -- 设置为 'mono'（Nerd Font Mono）或 'normal'（Nerd Font）
      nerd_font_variant = "mono",
    },

    -- 默认启用的提供者列表
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
  opts_extend = { "sources.default" },
}
