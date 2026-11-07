# tmux package
Deploys `.tmux/` → `~/.tmux` (whole dir stowed, fully tracked, no runtime state).

## Files
- `tmux.conf` — main config: pane/window bindings, borders, status line, `word-separators`, repo-scoped window list.
- `plugins/init.conf` — sources each plugin file (mirrors nvim's `plugins/init.lua`).
- `plugins/vim-integration.conf` — `C-h/j/k/l` pane movement that forwards keys to a running (n)vim pane.
- `plugins/agent-sidebar.conf` — sidebar/picker bindings and hooks.
- `scripts/agent-report <agent> <state|clear> [name]` — agents report state into pane options.
- `scripts/agent-sidebar`, `scripts/agent-sidebar-toggle` — sidebar render loop and `<prefix>+s` toggle.
- `scripts/agent-picker` — `<prefix>+a` fzf agent picker.

## Decisions
- `~/.tmux.conf` is user-owned, not tracked; `setup.sh deploy` appends a `source-file <repo>/…/.tmux/tmux.conf` line if missing and replaces a stale stowed `~/.tmux.conf` symlink.
- `<prefix>+z` explicitly rebinds tmux's default zoom for discoverability; zoom shows via `#F`'s `Z` flag.
- Pane borders: `pane-border-lines double` + `pane-border-status top`, active pane green.
- `status-left` shows a vi-mode indicator: copy-mode (NORMAL/VISUAL) wins, else pane option `@vimode` set by `zsh/.../vi-mode.zsh` (unset while a command runs → hidden).
- `word-separators` omits `.` and `-` so double-click selects whole IPs and hyphenated names.
- `window-status-format` hides windows whose `@repo` (git common dir) differs from the active one's, mirrored to session option `@active_repo` by hooks; worktrees share their main checkout's key.
- Agent state lives in pane options `@agent`/`@agent_name`/`@agent_state`/`@agent_cmd`; panes whose current command differs from `@agent_cmd` are stale. Reports signal `wait-for agents-changed`.
- Sidebar is a left `@sidebar` pane in the current window only; render loop blocks on wait-for with a 30s git refresh tick. `<prefix>+s` overrides the default session chooser.
- Focus bounces off sidebars; `done` turns `idle` on pane focus.
- Test with `command tmux -S <sock> -f /dev/null …`; `tmux` is a shell alias that swallows flags.

## Tests
- `tests/tmux.sh`, `tests/setup-script.sh`.

## TODO
- none
