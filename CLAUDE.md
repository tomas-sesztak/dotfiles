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
- `setup.sh` exists: discovers every top-level directory (except `.git`) as a Stow package and runs `stow -R`/`stow -D` against `$HOME`
- Stow packages:
	- `claude/` — stows the entire `~/.claude` directory (per Goal: manage directories where possible, not single files), so `~/.claude` itself becomes a symlink into `claude/.claude/` in this repo. This means `claude/.claude/` holds real runtime/secret state (credentials, sessions, history, caches, etc.) alongside the config we actually want to version. Design pattern: `.gitignore` allowlists `claude/.claude/` — ignore everything (`claude/.claude/**`), then `!`-negate only the specific files that should be tracked (currently `CLAUDE.md` and `settings.json`). Any new file to be versioned from that directory needs its own `!` negation line.
	- `nvim/` — stows the entire `~/.config/nvim` directory, so `~/.config/nvim` becomes a symlink into `nvim/.config/nvim/` in this repo. Unlike `claude/`, this directory holds only version-controlled config (no runtime/secret state), so no `.gitignore` allowlisting is needed — everything under it is tracked.
- No build/lint/test tooling exists; verify changes by running `./setup.sh deploy` and checking symlinks with `ls -la`
