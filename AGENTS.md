# Personal dotfiles repo
## Goal
- manage all personal dotfiles
- deploy to **$HOME** using GNU Stow
	- use script `setup.sh [deploy|undeploy]`
	- deploy redeploys (unstow & stow)
	- stow manages directories where possible, instead of single files

## Rules
- CLAUDE.md / AGENTS.md: Goal and Rules are managed by user, other sections by agents
- update README.md when hotkeys are changed
- test every change, note tools used
- always run `make` before a commit
- don't read color themes unless instructed to
- git: branch from fresh `develop` (not main); open PRs with `gh pr create --base develop`
- `develop` → `main` promotion is done by the user only
- `develop` is permanent: never delete it (local or remote), incl. after a develop → main merge (`gh pr merge` without `--delete-branch`)
- every merge to `main` is a release: annotated tag `vMAJOR.MINOR.PATCH` (SemVer) on the `develop` commit being released (before merging to `main`), so both branches have it; MAJOR = breaking (removed/renamed hotkeys, changes needing manual steps), MINOR = features, PATCH = fixes

## Current State
- `setup.sh [deploy|undeploy] [--no-claude]`: auto-discovers each top-level dir under `stow_modules/` as a Stow package and runs `stow -R`/`stow -D` against `$HOME`; `--no-claude` skips `claude/`. Stow ignores `AGENTS.md` so per-package docs aren't deployed.
- File maps, decisions and TODOs live in per-area `AGENTS.md` files; read the relevant one before changing that area and keep it current:
	- `stow_modules/<pkg>/AGENTS.md`: `bash`, `claude`, `copilot`, `herdr`, `homebrew`, `nvim`, `tmux`, `vim`, `zsh`
	- `tests/AGENTS.md`
