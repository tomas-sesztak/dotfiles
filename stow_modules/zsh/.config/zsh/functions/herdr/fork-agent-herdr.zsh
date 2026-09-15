function _fork-agent-herdr {
	local agent="$1" worktree_name="$2"
	local -a command_arg=("${@:3}")

	command -v herdr >/dev/null 2>&1 || {
		echo "fork-agent: herdr not found in PATH" >&2
		return 1
	}
	command -v jq >/dev/null 2>&1 || {
		echo "fork-agent: jq not found in PATH" >&2
		return 1
	}

	command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		echo "fork-agent: not inside a git repository" >&2
		return 1
	}

	local agent_name
	agent_name="$(_agent-sanitize-name "$worktree_name")"

	local pane
	pane="$(command herdr worktree create --workspace "$HERDR_WORKSPACE_ID" --branch "$worktree_name" --label "$worktree_name" --no-focus 2>/dev/null | jq -r '.result.root_pane.pane_id // empty')"
	if [ -z "$pane" ]; then
		echo "fork-agent: failed to create worktree $worktree_name" >&2
		return 1
	fi

	local -a start_args=(agent start "$agent_name" --kind "$agent" --pane "$pane")
	case "$agent" in
		claude) start_args+=(-- -n "$agent_name") ;;
	esac

	local tries=0
	until command herdr "${start_args[@]}" >/dev/null 2>&1; do
		(( tries++ >= 10 )) && {
			echo "fork-agent: failed to start agent in worktree $worktree_name" >&2
			return 1
		}
		sleep 0.3
	done

	if (( $#command_arg )); then
		command herdr agent prompt "$agent_name" "${command_arg[-1]}" >/dev/null 2>&1
	fi
	return 0
}
