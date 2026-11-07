# nvim package
Deploys `.config/nvim/` → `~/.config/nvim` (whole dir stowed, fully tracked, no runtime state).

## Files
- `init.lua` — entry point.
- `lua/tomas-sesztak/core/` — `options`, `keymaps`, `fzf`, `lsp`, `deps` (aggregated by `core/init.lua`).
- `lua/tomas-sesztak/plugins/` — `fzf`, `tmux` (aggregated by `plugins/init.lua`).
- `lsp/*.lua` — per-server configs (`ansiblels`, `bashls`, `lua_ls`, `yamlls`).
- `colors/` — color theme (don't read unless instructed).

## Decisions
- Every plugin/LSP server checks its external binaries on startup via `core/deps.lua` (`vim.fn.executable`, deferred `vim.notify` on ERROR); never blocks startup.
- `plugins/fzf.lua` and `plugins/tmux.lua` only warn on missing deps.
- `core/lsp.lua` gates `vim.lsp.enable()` per server on its `cmd[1]` binary; secondary tools come from each `lsp/*.lua`'s own `deps` field and only warn (e.g. `shellcheck` for `bashls`; linting only, no formatter).

## Tests
- `tests/editors.sh` (headless startup without errors).

## TODO
- none
