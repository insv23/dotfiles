return {
  {
    "stevearc/conform.nvim",
    opts = function()
      local opts = {
        formatters_by_ft = {
          python = { "black" },
          lua = { "stylua" },
        },
        formatters = {
          black = {
            prepend_args = { "--line-length", "79" }, -- Example: Set line length
          },
        },
      }
      return opts
    end,
  },
}
