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
- Repo is scaffolding only: `CLAUDE.md`, `AGENTS.md` (symlink to `CLAUDE.md`), `LICENSE`
- `setup.sh` referenced in Goal does not exist yet — no dotfiles or Stow packages have been added
- No build/lint/test tooling exists; nothing to run yet
