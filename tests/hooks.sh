#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

CLAUDE_HOOK="$MODULES/claude/.claude/hooks/tmux-agent-state.sh"
COPILOT_HOOK="$MODULES/copilot/.copilot/hooks/tmux-agent-state.sh"
LOG="$SANDBOX/report.log"

mkdir -p "$HOME/.tmux/scripts"
# shellcheck disable=SC2016
printf '#!/bin/sh\nprintf "%%s|" "$@" >>"%s"\n' "$LOG" >"$HOME/.tmux/scripts/agent-report"
chmod +x "$HOME/.tmux/scripts/agent-report"

# run_hook <hook> <json>: prints what the hook reported
run_hook() {
	: >"$LOG"
	TMUX_PANE=%1 sh "$1" <<<"$2"
	cat "$LOG"
}

event() {
	jq -nc --arg e "$1" '{hook_event_name: $e}'
}

check_state() {
	local hook=$1 agent=$2 event_name=$3 state=$4
	assert_eq "$agent $event_name" "$agent|$state||" "$(run_hook "$hook" "$(event "$event_name")")"
}

for hook_agent in "$CLAUDE_HOOK:claude" "$COPILOT_HOOK:copilot"; do
	hook=${hook_agent%:*} agent=${hook_agent##*:}
	check_state "$hook" "$agent" SessionStart idle
	check_state "$hook" "$agent" UserPromptSubmit working
	check_state "$hook" "$agent" PostToolUse working
	check_state "$hook" "$agent" PostToolUseFailure working
	check_state "$hook" "$agent" PreToolUse blocked
	check_state "$hook" "$agent" Notification blocked
	check_state "$hook" "$agent" Stop "done"
	assert_eq "$agent SessionEnd" "$agent|clear|" "$(run_hook "$hook" "$(event SessionEnd)")"
	assert_eq "$agent unknown event" "" "$(run_hook "$hook" "$(event Whatever)")"
	assert_eq "$agent invalid JSON" "" "$(run_hook "$hook" 'not json')"

	: >"$LOG"
	sh "$hook" <<<"$(event Stop)"
	assert_eq "$agent outside tmux" "" "$(cat "$LOG")"

	marker="$SANDBOX/injected"
	run_hook "$hook" "$(event "\$(touch $marker)")" >/dev/null
	assert_true "$agent event is not evaluated" test ! -e "$marker"
done

check_state "$CLAUDE_HOOK" claude PermissionRequest blocked
assert_eq "copilot ignores PermissionRequest" "" "$(run_hook "$COPILOT_HOOK" "$(event PermissionRequest)")"

transcript="$SANDBOX/transcript.jsonl"
printf '{"agentName":"first"}\n{"x":1}\n{"agentName":"last"}\n' >"$transcript"
with_transcript() {
	jq -nc --arg e "$1" --arg t "$transcript" '{hook_event_name: $e, transcript_path: $t}'
}
assert_eq "claude name from transcript" "claude|idle|last|" "$(run_hook "$CLAUDE_HOOK" "$(with_transcript SessionStart)")"
assert_eq "claude name only on some events" "claude|working||" "$(run_hook "$CLAUDE_HOOK" "$(with_transcript PostToolUse)")"

mkdir -p "$HOME/.copilot/session-state/s1" "$SANDBOX/alt/session-state/s1"
printf 'id: s1\nname: "my-agent"\n' >"$HOME/.copilot/session-state/s1/workspace.yaml"
printf "name: 'alt-agent'\n" >"$SANDBOX/alt/session-state/s1/workspace.yaml"
assert_eq "copilot name from session_id" "copilot|idle|my-agent|" \
	"$(run_hook "$COPILOT_HOOK" '{"hook_event_name":"SessionStart","session_id":"s1"}')"
assert_eq "copilot name from sessionId" "copilot|done|my-agent|" \
	"$(run_hook "$COPILOT_HOOK" '{"hook_event_name":"Stop","sessionId":"s1"}')"
assert_eq "copilot honours COPILOT_HOME" "copilot|idle|alt-agent|" \
	"$(COPILOT_HOME="$SANDBOX/alt" run_hook "$COPILOT_HOOK" '{"hook_event_name":"SessionStart","session_id":"s1"}')"
