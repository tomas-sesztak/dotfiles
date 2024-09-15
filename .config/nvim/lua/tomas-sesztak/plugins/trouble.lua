return {
  "folke/trouble.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {},
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble<CR>", desc = "Open/close trouble list" },
    { "<leader>xd", "<cmd>Trouble diagnostics<CR>", desc = "Open trouble diagnostics" },
    { "<leader>xc", "<cmd>Trouble diagnostics close<CR>", desc = "Close trouble diagnostics" },
    { "<leader>xq", "<cmd>Trouble quickfix<CR>", desc = "Open trouble quickfix list" },
    { "<leader>xl", "<cmd>Trouble loclist<CR>", desc = "Open trouble location list" },
  },
}
