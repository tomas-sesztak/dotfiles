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

## Current State
- `setup.sh [deploy|undeploy] [--no-claude]`: auto-discovers each top-level dir (except `.git`) as a Stow package, runs `stow -R`/`stow -D` against `$HOME`. `--no-claude` skips the `claude/` package — avoids unlinking `~/.claude` mid-session when testing other packages live.
- Packages:
	- `claude/` → `~/.claude` (whole dir stowed). Holds real runtime/secret state alongside tracked config; `.gitignore` allowlists via `claude/.claude/**` then `!`-negates tracked files (currently `CLAUDE.md`, `settings.json`). New trackable files need their own `!` line.
	- `nvim/` → `~/.config/nvim` (whole dir stowed, fully tracked — no runtime state here, no allowlisting needed).
	- `bash/` — stows `.bashrc` only (no shared subdir to stow as a whole). `.bash_profile`/`.bash_logout` remain unmanaged; `.bash_history` excluded (runtime state).
- No build/lint/test tooling; verify via `./setup.sh deploy` + `ls -la` on the resulting symlinks.
