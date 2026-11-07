# zsh package
Deploys `.config/zsh/functions` and `.config/zsh/completions` → `~/.config/zsh/` (whole dirs stowed).

## Files
- `functions/init/init.zsh` — entry point; Homebrew paths (incl. gnu-sed `gnubin`) on macOS, then sources everything else.
- `functions/late/syntax.zsh` — zsh-syntax-highlighting, sourced last.
- `functions/options.zsh` — global env exports (`EDITOR`, `HELM_REPOSITORY_CONFIG`).
- `functions/{alias,autosuggestions,fzf,history,path,prompt,oc,weather}.zsh` — shell config and small functions.
- `functions/vi-mode.zsh` — vi line editing; sets tmux pane option `@vimode` via ZLE hooks.
- `functions/tmux-repo.zsh` — tags tmux windows with `@repo`.
- `functions/brew.zsh` — `brew_update` (see `homebrew/AGENTS.md`).
- `functions/completions.zsh` — `generate_completions()`.
- `functions/{init-agents,fork-agent,cleanup-agents}.zsh` — dispatchers and `-help` functions.
- `functions/tmux/*-tmux.zsh`, `functions/herdr/*-herdr.zsh` — per-multiplexer implementations.
- `functions/herdr/herdr-reset.zsh` — `herdr-reset [-y]`: closes every workspace (current one last), opens a fresh one in `$HOME`; prompts unless `-y`.
- `functions/helpers/_agent-sanitize-name.zsh`, `functions/helpers/_git-repo-key.zsh` — shared helpers.
- `completions/_*` — generated completion files.

## Decisions
- `~/.zshrc` is user-owned, not tracked; `setup.sh deploy` appends a `source <repo>/…/functions/init/init.zsh` line if missing and replaces a stale stowed `~/.zshrc` symlink.
- `init.zsh` globs and sources `functions/**/*.zsh` except `init/` and `late/`, then `late/*.zsh`; syntax highlighting must load after all ZLE widgets.
- Completion files are tracked; regenerate via `generate_completions()` and commit the diff.
- Agent scripts auto-detect the multiplexer: herdr first (`$HERDR_ENV`/`$HERDR_WORKSPACE_ID`), then tmux (`$TMUX`); error outside both. All take `-h`/`--help`.
- Each tmux/herdr implementation lives in its own file; top-level files hold only the dispatcher and `-help`.
- `init-agents -a <agent> -p <path>`: one window/workspace per top-level git repo under `<path>`, launching `<agent>` where missing; herdr mode auto-starts the herdr server.
- `fork-agent -a <agent> -w <name> [-c "<cmd>"]` under herdr: `herdr worktree create` (repo from `$HERDR_WORKSPACE_ID`); `<cmd>` sent via `herdr agent prompt` once the agent runs.
- `fork-agent` under tmux: plain `git worktree add` at `<parent-of-repo>/git-worktrees/<name>`, new unfocused window `<name>`; `<cmd>` is a trailing launch argument (no send-after mechanism).
- Under tmux, scripts type the agent command into the pane shell (`send-keys`) so the pane survives the agent exiting; new windows get `@repo` via `_git-repo-key`.
- Agent identities (herdr agent names, claude/copilot `-n`/`--name`) go through `_agent-sanitize-name` (lowercase, disallowed chars → `-`, strip leading non-letters, max 32) to match herdr's `^[a-z][a-z0-9_-]{0,31}$`; window/workspace labels and branch names stay unsanitized.
- `cleanup-agents [-n]` closes only linked-worktree agents (never the main checkout) that are idle/done with a clean worktree (untracked counts as dirty), removing the worktree; `-n` is a dry run.
- `cleanup-agents` under herdr: `herdr agent list`'s `agent_status`, then one `herdr worktree remove --workspace <id>`.
- `cleanup-agents` under tmux: a window is closable once every live agent pane (`@agent_cmd` match) is idle/done and no unreported `claude`/`copilot`/`node` process runs in it.

## Tests
- `tests/tmux.sh` (agent scripts under tmux), `tests/sanitize.sh`, `tests/setup-script.sh`.

## TODO
- none
