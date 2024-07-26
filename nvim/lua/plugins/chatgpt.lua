return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        openai_params = {
          model = "claude-3-5-sonnet-20240620",
          max_tokens = 4095,
          temperature = 0.3,
        },
        openai_edit_params = {
          model = "claude-3-5-sonnet-20240620",
          max_tokens = 4095,
          temperature = 0.3,
        },
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
