# homebrew package
Deploys `.Brewfile_dotfiles` → `~/.Brewfile_dotfiles`.

## Files
- `.Brewfile_dotfiles` — Homebrew packages the dotfiles need.

## Decisions
- `brew_update` (`zsh/.../brew.zsh`) merges it with optional user-owned `~/.Brewfile` into a `mktemp` file (unique entries, taps first) and syncs Homebrew to it.

## TODO
- none
