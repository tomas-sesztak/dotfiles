return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  settings = {
    yaml = {
      format = {
        enable = true,
        singleQuote = false,
        bracketSpacing = true,
      },
      -- Validation
      validate = true,
      completion = true,
      hover = true,
      schemaStore = {
        enable = false,
      },
    },
  },
}
