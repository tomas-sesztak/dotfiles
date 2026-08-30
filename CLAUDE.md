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
	- `copilot/` → `~/.copilot` (whole dir stowed). Contains a single tracked file, `copilot-instructions.md`, checked into git as a relative symlink to `claude/.claude/CLAUDE.md` — same trick as the repo-root `AGENTS.md -> CLAUDE.md` symlink, one level deeper. Resolves regardless of stow deployment state since it's relative within the repo tree; keeps GitHub Copilot CLI's global instructions (`~/.copilot/copilot-instructions.md`) in sync with Claude's without duplicated content.
	- `nvim/` → `~/.config/nvim` (whole dir stowed, fully tracked — no runtime state here, no allowlisting needed). Every plugin/LSP server checks its external binary deps on startup via `lua/tomas-sesztak/core/deps.lua` (`vim.fn.executable`, deferred `vim.notify` on ERROR — never blocks startup). `plugins/fzf.lua` and `plugins/tmux.lua` warn only; `core/lsp.lua` gates `vim.lsp.enable()` per server on its primary binary (`cmd[1]`) being present, and separately warns on missing secondary tools declared via each `lsp/*.lua` file's own `deps` field (e.g. `shellcheck`/`shfmt` for `bashls`).
	- `bash/` — stows `.bashrc` only (no shared subdir to stow as a whole). `.bash_profile`/`.bash_logout` remain unmanaged; `.bash_history` excluded (runtime state).
	- `tmux/` → `~/.tmux.conf` + `~/.tmux` (whole dir stowed). Fully tracked, no runtime state. `~/.tmux.conf` sources `~/.tmux/plugins/init.conf` (mirrors nvim's `plugins/init.lua` aggregator), which sources each plugin file in `.tmux/plugins/`. First plugin: `vim-integration.conf`, holding the `C-h/j/k/l` pane-movement bindings that detect a running (n)vim pane and forward the keys to it instead of switching tmux panes.
	- `vim/` → `~/.vimrc` + `~/.vim` (whole dir stowed). Fully tracked, no runtime state. `~/.vimrc` sources `~/.vim/config/tmux.vim`, which was never present on disk and isn't tracked — that `source` line errors non-fatally on every startup until the file is added.
	- `zsh/` → `~/.zshrc` + `~/.config/zsh/functions` (whole dir stowed). `~/.zshrc` globs and sources every `~/.config/zsh/functions/**/*.zsh` file. `~/.config/zsh/completions` is excluded — it's generated at runtime by `generate_completions()` (defined in `functions/completions.zsh`), not tracked.
	- `herdr/` → `~/.config/herdr` (whole dir stowed). Same allowlist trick as `claude/`: `.gitignore` has `herdr/.config/herdr/**` then `!herdr/.config/herdr/config.toml`. Everything else in the directory (`session.json`, `herdr-client.log`, `herdr-server.log`, `herdr.sock`, `herdr-client.sock`, `.plugins.lock`) is live runtime state — sockets and logs from the running herdr client/server, session layout — regenerated on its own; it lives on disk under the symlinked path but stays untracked.
- No build/lint/test tooling; verify via `./setup.sh deploy` + `ls -la` on the resulting symlinks.
