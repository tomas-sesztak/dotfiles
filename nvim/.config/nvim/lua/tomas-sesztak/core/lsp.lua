local deps = require("tomas-sesztak.core.deps")

local servers = {
  "ansiblels",
  "bashls",
  "lua_ls",
  "yamlls",
}

local available = {}
for _, name in ipairs(servers) do
  local cfg = vim.lsp.config[name]
  local primary = cfg and type(cfg.cmd) == "table" and cfg.cmd[1]

  if primary and vim.fn.executable(primary) == 1 then
    table.insert(available, name)
    if cfg.deps then
      deps.check(name, cfg.deps)
    end
  else
    deps.check(name, { primary or name })
  end
end

vim.lsp.enable(available)

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})

vim.filetype.add({
  pattern = {
    [".*/playbooks/.*%.yml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.yml"] = "yaml.ansible",
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    -- If this is the YAML server but the file is Ansible, detach it.
    if client.name == "yaml-ls" and vim.bo[bufnr].filetype == 'yaml.ansible' then
      vim.lsp.buf_detach_client(bufnr, client.id)
      return
    end

    vim.keymap.set('n', '<leader>ds', vim.diagnostic.open_float, { buffer = bufnr })

    if client:supports_method('textDocument/completion') then
      vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      vim.keymap.set('i', '<leader>cc', function()
        vim.lsp.completion.get()
      end)
    end
  end
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Only setup format-on-save if the server supports formatting
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({
            bufnr = args.buf,
            id = client.id
          })
        end,
      })
    end
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf, desc = "LSP Format Buffer" }
    -- The Manual Shortcut
    vim.keymap.set('n', '<leader>cf', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- Navigate up/down when completion menu is visible
vim.keymap.set('i', '<C-j>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<C-j>'
end, { expr = true, noremap = true })

vim.keymap.set('i', '<C-k>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<C-k>'
end, { expr = true, noremap = true })
