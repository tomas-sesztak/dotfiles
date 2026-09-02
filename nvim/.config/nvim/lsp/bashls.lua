return {
  name = "bashls",
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  deps = { "shellcheck" },
  settings = {
    bashIde = {
      -- Background analysis and globbing
      globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
      explanationHintsConfig = {
        enabled = true, -- Provides hover explanations for shell commands
      },

      -- Linting Settings (requires 'shellcheck' installed)
      shellcheckPath = "shellcheck",
    },
  },
}
