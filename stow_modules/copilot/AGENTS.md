# copilot package
Deploys `.copilot/` → `~/.copilot` (whole dir stowed).

## Files
- `settings.json` — Copilot CLI settings (vim editor mode, footer fields).
- `copilot-instructions.md` — Copilot CLI global instructions.
- `hooks/guard-destructive.{json,sh,rules}` — `preToolUse` hook on `bash` returning `permissionDecision: "ask"` for destructive commands.
- `hooks/tmux-agent-state.{json,sh}` — Copilot counterpart of Claude's tmux sidebar hook.

## Decisions
- `copilot-instructions.md` is a regular file, maintained separately from `claude/.claude/CLAUDE.md`.
- Hooks are user-level, loaded at CLI start.
- guard: rules are human-editable, one `flags :: label :: ERE [:: unless-ERE]` per line; needs `jq`.
- guard: missing rules file, malformed line or unparsable input → ask; errors fail closed, timeouts fail open.
- guard: "ask" is enforced even under `--allow-all-tools`/autopilot; non-interactive (`-p`) sessions turn it into deny.
- guard covers `find -delete`, `git push --force`, any `kubectl`/`oc` op that changes cluster state or the active kubeconfig/context, and ops printing secret values; standalone `--dry-run=client|server` is exempt for create/apply-style ops.
- tmux hook uses PascalCase events; agent name is read from `session-state/<id>/workspace.yaml`.

## Tests
- `tests/guard.sh`, `tests/hooks.sh`.

## TODO
- README's package table still says `copilot-instructions.md` symlinks to Claude's `CLAUDE.md`; it's a regular file.
