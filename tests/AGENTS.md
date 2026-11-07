# tests
Local only (no hooks/CI); run via `make` (`lint`, `unit`, `integration`).

## Files
- `lib.sh` — sourced by each test: assertions, temp `HOME`/XDG dirs, private tmux socket, cleanup trap.
- `guard.sh` (unit) — copilot `guard-destructive` rules.
- `sanitize.sh` (unit) — `_agent-sanitize-name`.
- `hooks.sh` (unit) — claude/copilot tmux agent-state hooks.
- `setup-script.sh` (integration) — `setup.sh` deploy/undeploy, source lines, `--no-claude`, conflicts.
- `tmux.sh` (integration) — tmux config and agent scripts on an isolated server.
- `editors.sh` (integration) — nvim and vim start without errors.

## Decisions
- Tests never touch the real setup: temp `HOME`, unset `TMUX`/`HERDR_*`/`GIT_DIR`, isolated git config.
- Use `command tmux -S <sock> -f /dev/null …`; `tmux` is a shell alias that swallows flags.
- Each test script runs even after an earlier one fails; a script with zero passes counts as failed.
- `make lint`: `zsh -n`, `bash -n`, `shellcheck`, `jq` for JSON, `tomllib` for TOML.
- New test scripts must be added to the `unit` or `integration` list in `Makefile`.

## TODO
- none
