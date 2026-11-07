# vim package
Deploys `.vimrc` → `~/.vimrc` and `.vim/` → `~/.vim` (whole dir stowed, fully tracked, no runtime state).

## Files
- `.vimrc` — main config; sources `~/.vim/config/{deps,fzf,tmux}.vim`.
- `.vim/config/deps.vim` — external binary checks.
- `.vim/config/fzf.vim` — fuzzy find mappings.
- `.vim/config/tmux.vim` — `TmuxMove()`, mapped to `C-h/j/k/l` in `.vimrc`.
- `.vim/colors/` — color theme (don't read unless instructed).

## Decisions
- `TmuxMove()` falls back to `tmux select-pane` at the split edge; tmux only, no herdr fallback.

## Tests
- `tests/editors.sh`.

## TODO
- none
