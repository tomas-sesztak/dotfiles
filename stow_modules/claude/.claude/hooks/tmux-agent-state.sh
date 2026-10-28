#!/bin/sh
# Claude Code hook → tmux agent sidebar: maps hook events to agent states for ~/.tmux/scripts/agent-report
report="$HOME/.tmux/scripts/agent-report"
[ -n "${TMUX_PANE:-}" ] && [ -x "$report" ] && command -v jq >/dev/null 2>&1 || exit 0

eval "$(jq -r '@sh "event=\(.hook_event_name // "") transcript=\(.transcript_path // "")"' 2>/dev/null)"

case ${event:-} in
SessionStart) state=idle ;;
UserPromptSubmit | PostToolUse | PostToolUseFailure) state=working ;;
PreToolUse | PermissionRequest | Notification) state=blocked ;;
Stop) state="done" ;;
SessionEnd) exec "$report" claude clear ;;
*) exit 0 ;;
esac

# session name (-n / /rename) is recorded in the transcript
name=''
case $event in
SessionStart | UserPromptSubmit | Stop)
	[ -f "${transcript:-}" ] &&
		name=$(grep -o '"agentName":"[^"]*"' "$transcript" | tail -n 1 | sed 's/^"agentName":"//; s/"$//')
	;;
esac
exec "$report" claude "$state" "$name"
