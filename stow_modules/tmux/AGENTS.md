# tmux package
Deploys `.tmux/` → `~/.tmux` (whole dir stowed, fully tracked, no runtime state).

## Files
- `tmux.conf` — main config: pane/window bindings, borders, status line, `word-separators`, agent-filtered window list.
- `plugins/init.conf` — sources each plugin file (mirrors nvim's `plugins/init.lua`).
- `plugins/vim-integration.conf` — `C-h/j/k/l` pane movement that forwards keys to a running (n)vim pane.
- `plugins/agents.conf` — picker binding, done→idle focus hook.
- `scripts/agent-report <agent> <state|clear> [name]` — agents report state into pane options.
- `scripts/agent-picker [client]` — `<prefix>+a` fzf agent picker.
- `scripts/window-switcher [dir]` — `<prefix>+w` fzf window switcher; creates a window on no match.
- `scripts/dotfiles-update-check` — `status-right` segment: red `⬇ dotfiles N` block when local `main` is behind `origin/main`.

## Decisions
- `~/.tmux.conf` is user-owned, not tracked; `setup.sh deploy` appends a `source-file <repo>/…/.tmux/tmux.conf` line if missing and replaces a stale stowed `~/.tmux.conf` symlink.
- `<prefix>+z` explicitly rebinds tmux's default zoom for discoverability; zoom shows via `#F`'s `Z` flag.
- Pane borders: `pane-border-lines double` + `pane-border-status top`, active pane green.
- `status-left` shows a vi-mode indicator: copy-mode (NORMAL/VISUAL) wins, else pane option `@vimode` set by `zsh/.../vi-mode.zsh` (unset while a command runs → hidden).
- `word-separators` omits `.` and `-` so double-click selects whole IPs and hyphenated names.
- Status bar shows the current window plus windows with a live agent pane (any state), via a `#{P:}` pane loop in `window-status-format`.
- Agent state lives in pane options `@agent`/`@agent_name`/`@agent_state`/`@agent_cmd`; panes whose current command differs from `@agent_cmd` are stale. Reports run `refresh-client -S` on all clients; unreported exits drop off at the next `status-interval`.
- `done` turns `idle` on pane focus. `<prefix>+s` is explicitly rebound to the default session chooser.
- Popup bindings never paste formats into a nested shell string: `<prefix>+w` passes the cwd via `display-popup -d`, `<prefix>+a` passes the client via `-e AGENT_CLIENT=#{q:client_name}`.
- Window switcher: Enter with no match (or alt-enter) asks for a dir: children of the pane dir's parent, or a typed existing path; Esc cancels.
- Update check: background `git fetch origin main` at most hourly (stamp `$XDG_CACHE_HOME/dotfiles/last-fetch`, touched before fetching so failures also wait an hour); SSH in `BatchMode` so it never prompts; alert only, no pull.
- Test with `command tmux -S <sock> -f /dev/null …`; `tmux` is a shell alias that swallows flags.

## Tests
- `tests/tmux.sh`, `tests/setup-script.sh`.

## TODO
- none
