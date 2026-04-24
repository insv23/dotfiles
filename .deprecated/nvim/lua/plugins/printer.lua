return {
  {
    "rareitems/printer.nvim",
    config = function()
      require("printer").setup({
        keymap = "gp", -- 默认需要在 v 模式下才生效
        behavior = "insert_below", -- 在当前行下方插入
        formatters = {
          -- 自定义不同语言的打印格式
          lua = function(inside, variable)
            return string.format('print("%s: " .. %s)', inside, variable)
          end,
        },
      })

      -- 在普通模式下，“gp” 会触发插件的打印功能，并自动应用于 “inner word”（iw）。
      -- 这意味着它会为光标所在的整个单词生成一个打印语句。
      vim.keymap.set("n", "gp", "<Plug>(printer_print)iw")
    end,
  },
}
