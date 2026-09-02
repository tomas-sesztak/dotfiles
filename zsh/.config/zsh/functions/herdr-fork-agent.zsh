function herdr-fork-agent {
	local -a opt_agent opt_worktree opt_command opt_help
	zparseopts -D -E -- a:=opt_agent w:=opt_worktree c:=opt_command h=opt_help -help=opt_help
	if (( $? )) || (( $#opt_help )) || (( ! $#opt_agent )) || (( ! $#opt_worktree )); then
		herdr-fork-agent-help
		return 1
	fi

	local agent="${opt_agent[-1]}" worktree_name="${opt_worktree[-1]}"

	if [ "$HERDR_ENV" != "1" ] || [ -z "$HERDR_WORKSPACE_ID" ]; then
		echo "herdr-fork-agent: must be run from inside an active herdr workspace" >&2
		return 1
	fi

	command -v herdr >/dev/null 2>&1 || {
		echo "herdr-fork-agent: herdr not found in PATH" >&2
		return 1
	}
	command -v jq >/dev/null 2>&1 || {
		echo "herdr-fork-agent: jq not found in PATH" >&2
		return 1
	}

	command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		echo "herdr-fork-agent: not inside a git repository" >&2
		return 1
	}

	local pane
	pane="$(command herdr worktree create --workspace "$HERDR_WORKSPACE_ID" --branch "$worktree_name" --label "$worktree_name" --no-focus 2>/dev/null | jq -r '.result.root_pane.pane_id // empty')"
	if [ -z "$pane" ]; then
		echo "herdr-fork-agent: failed to create worktree $worktree_name" >&2
		return 1
	fi

	local -a start_args=(agent start "$worktree_name" --kind "$agent" --pane "$pane")
	case "$agent" in
		claude) start_args+=(-- -n "$worktree_name") ;;
	esac
	command herdr "${start_args[@]}" >/dev/null 2>&1 || {
		echo "herdr-fork-agent: failed to start agent in worktree $worktree_name" >&2
		return 1
	}

	if (( $#opt_command )); then
		command herdr agent prompt "$worktree_name" "${opt_command[-1]}" >/dev/null 2>&1
	fi
}

function herdr-fork-agent-help {
	cat <<-EOF
	Usage: herdr-fork-agent -a <agent> -w <worktree_name> [-c "<command>"]

	  Fork the current git project into a new herdr-managed git worktree and
	  start <agent> inside it. The repo is resolved from the current herdr
	  workspace (\$HERDR_WORKSPACE_ID), so this must be run from inside an
	  active herdr pane sitting in the project you want to fork.

	  -a <agent>          Agent kind to launch (passed to \`herdr agent start
	                      --kind\`). Run \`herdr agent start --help\` for the
	                      supported list (e.g. claude, codex, copilot, gemini).
	                      When <agent> is claude, its session is named after
	                      <worktree_name> via -n.
	  -w <worktree_name>  Name for the new git branch/worktree, also used as
	                      the herdr agent name.
	  -c <command>        Optional prompt sent to the agent once it's running
	                      (via \`herdr agent prompt\`).
	  -h, --help          Show this help.
	EOF
}
