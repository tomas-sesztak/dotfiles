return {
  "williamboman/mason.nvim", -- lsp manager
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- enable mason and configure icons
    mason.setup()

    mason_lspconfig.setup({
      -- list of lsp servers for mason to install
      ensure_installed = {
        -- lsp
        "ansiblels",
        "bashls",
        "lua_ls",
        "pylsp",
        "yamlls",
      },
    })

    local mason_tool_installer = require("mason-tool-installer")
    mason_tool_installer.setup({
      ensure_installed = {
        -- formatter
        "beautysh",
        "prettier",
        "stylua",
      },
    })

    local keymap = vim.keymap
    -- setup mason keybind
    keymap.set("n", "<leader>M", "<cmd>:Mason<CR>", { desc = "Open Mason" })
  end,
}
