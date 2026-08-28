# Personal dotfiles repo
## Goal
- manage all personal dotfiles
- deploy to **$HOME** using GNU Stow
	- use script `setup.sh [deploy|undeploy]`
	- deploy redeploys (unstow & stow)
	- stow manages directories where possible, instead of single files

## Rules
- CLAUDE.md / AGENTS.md: Goal and Rules are managed by user, other sections by agents
- test every change, note tools used
- don't read color themes unless instructed to

## Current State
- `setup.sh [deploy|undeploy] [--no-claude]`: auto-discovers each top-level dir (except `.git`) as a Stow package, runs `stow -R`/`stow -D` against `$HOME`. `--no-claude` skips the `claude/` package — avoids unlinking `~/.claude` mid-session when testing other packages live.
- Packages:
	- `claude/` → `~/.claude` (whole dir stowed). Holds real runtime/secret state alongside tracked config; `.gitignore` allowlists via `claude/.claude/**` then `!`-negates tracked files (currently `CLAUDE.md`, `settings.json`). New trackable files need their own `!` line.
	- `nvim/` → `~/.config/nvim` (whole dir stowed, fully tracked — no runtime state here, no allowlisting needed). Every plugin/LSP server checks its external binary deps on startup via `lua/tomas-sesztak/core/deps.lua` (`vim.fn.executable`, deferred `vim.notify` on ERROR — never blocks startup). `plugins/fzf.lua` and `plugins/tmux.lua` warn only; `core/lsp.lua` gates `vim.lsp.enable()` per server on its primary binary (`cmd[1]`) being present, and separately warns on missing secondary tools declared via each `lsp/*.lua` file's own `deps` field (e.g. `shellcheck`/`shfmt` for `bashls`).
	- `bash/` — stows `.bashrc` only (no shared subdir to stow as a whole). `.bash_profile`/`.bash_logout` remain unmanaged; `.bash_history` excluded (runtime state).
	- `tmux/` — stows `.tmux.conf` only (no shared subdir to stow as a whole). Fully tracked, no runtime state.
	- `vim/` → `~/.vimrc` + `~/.vim` (whole dir stowed). Fully tracked, no runtime state. `~/.vimrc` sources `~/.vim/config/tmux.vim`, which was never present on disk and isn't tracked — that `source` line errors non-fatally on every startup until the file is added.
- No build/lint/test tooling; verify via `./setup.sh deploy` + `ls -la` on the resulting symlinks.
