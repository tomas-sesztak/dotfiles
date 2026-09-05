return {
  name = "ansible-ls",
  cmd = { "ansible-language-server", "--stdio" },
  filetypes = { "yaml.ansible" },
  deps = { "ansible", "python3", "ansible-lint" },
  settings = {
    ansible = {
      ansible = {
        path = "ansible",
      },
      executionEnvironment = {
        enabled = false,
      },
      python = {
        interpreterPath = "python3",
      },
      validation = {
        enabled = true,
        lint = {
          enabled = true,
          path = "ansible-lint",
        },
      },
    },
  },
}
