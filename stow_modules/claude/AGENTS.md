# claude package
Deploys `.claude/` → `~/.claude` (whole dir stowed).

## Files
- `CLAUDE.md` — global Claude Code instructions.
- `settings.json` — Claude Code settings; wires hooks and the status line.
- `statusline-command.sh` — two-line status line (model/repo/branch, rate-limit bars).
- `hooks/herdr-agent-state.sh` — herdr session-identity hook (pane labels/notifications), wired into `hooks.SessionStart`.
- `hooks/tmux-agent-state.sh` — maps Claude hook events to tmux sidebar states via `~/.tmux/scripts/agent-report`; no-op outside tmux.
- `skills/*/SKILL.md` — user skills (`fork-agent`, `init-agents`, `cleanup-agents`, `fix-issues`).

## Decisions
- `~/.claude` holds real runtime/secret state; root `.gitignore` ignores `stow_modules/claude/.claude/**` and `!`-negates tracked files (nested files need their dir negated too).
- `hooks/herdr-agent-state.sh` comes from `herdr integration install claude`; reinstalling overwrites it, tracked for reproducibility.
- `setup.sh --no-claude` exists so testing other packages doesn't unlink `~/.claude` mid-session.

## Tests
- `tests/hooks.sh` (tmux state hook), `tests/setup-script.sh` (stow link).

## TODO
- none
