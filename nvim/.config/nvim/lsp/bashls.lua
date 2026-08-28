return {
  name = "bashls",
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  deps = { "shellcheck", "shfmt" },
  settings = {
    bashIde = {
      -- Background analysis and globbing
      globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
      explanationHintsConfig = {
        enabled = true, -- Provides hover explanations for shell commands
      },

      -- Linting Settings (requires 'shellcheck' installed)
      shellcheckPath = "shellcheck",
      --shellcheckArguments = "--shell=bash", -- Force bash dialect or remove for auto

      -- Formatting Settings (requires 'shfmt' installed)
      shfmt = {
        path = "shfmt",
        ignoreEditorconfig = false,
        languageDialect = "auto", -- auto, bash, posix, mksh, or bats
        binaryNextLine = true,    -- Binary ops like && and | start a line
        caseIndent = true,        -- Indent switch cases
        funcNextLine = false,     -- Place { on new line?
        spaceRedirects = false,   -- Add space after > or <
        simplifyCode = false,     -- Simplify code while formatting
      },
    },
  },
}
