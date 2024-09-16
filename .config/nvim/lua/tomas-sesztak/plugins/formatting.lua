return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        bash = { "beautysh" },
        lua = { "stylua" },
        sh = { "beautysh" },
        yaml = { "prettier" },
        zsh = { "beautysh" },
      },
      -- Disabled automatic formatting
      --format_on_save = {
      --  lsp_fallback = true,
      --  async = false,
      --  timeout_ms = 1000,
      --},
    })

    local keymap = vim.keymap
    keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visueal mode)" })
  end,
}
