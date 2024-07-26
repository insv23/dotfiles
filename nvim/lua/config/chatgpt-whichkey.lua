local wk = require("which-key")

wk.add({
  {
    -- mode = { "n", "v" }, -- NORMAL and VISUAL mode
    { "<leader>tt", "<cmd>ChatGPT<CR>", desc = "Chat GPT" }, -- no need to specify mode since it's inherited
    { "<leader>te", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" }, -- no need to specify mode since it's inherited
  },
})
