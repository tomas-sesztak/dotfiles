#!/bin/sh
# Copilot CLI hook → tmux agent sidebar: maps hook events to agent states for ~/.tmux/scripts/agent-report
report="$HOME/.tmux/scripts/agent-report"
[ -n "${TMUX_PANE:-}" ] && [ -x "$report" ] && command -v jq >/dev/null 2>&1 || exit 0

eval "$(jq -r '@sh "event=\(.hook_event_name // "") session=\(.session_id // .sessionId // "")"' 2>/dev/null)"

case ${event:-} in
SessionStart) state=idle ;;
UserPromptSubmit | PostToolUse | PostToolUseFailure) state=working ;;
PreToolUse | Notification) state=blocked ;;
Stop) state="done" ;;
SessionEnd) exec "$report" copilot clear ;;
*) exit 0 ;;
esac

# session name (--name) is recorded in the session's workspace.yaml
name=''
case $event in
SessionStart | UserPromptSubmit | Stop)
	ws="${COPILOT_HOME:-$HOME/.copilot}/session-state/${session:-none}/workspace.yaml"
	[ -f "$ws" ] && name=$(sed -n 's/^name: *//p' "$ws" | head -n 1 | tr -d "\"'")
	;;
esac
exec "$report" copilot "$state" "$name"
