# herdr package
Deploys `.config/herdr/` → `~/.config/herdr` (whole dir stowed).

## Files
- `config.toml` — herdr config.
- `scripts/smart-pane-nav.sh` — `C-h/j/k/l` pane navigation that hands keys to editor panes at the split edge.

## Decisions
- Same allowlist trick as `claude/`: only the files above are tracked; `session.json`, `*.log`, `*.sock`, `.plugins.lock` are untracked runtime state.

## Tests
- `tests/setup-script.sh` (stow link); `make lint` parses `config.toml`.

## TODO
- none
