function fork-agent {
	local -a opt_agent opt_worktree opt_command opt_help
	zparseopts -D -E -- a:=opt_agent w:=opt_worktree c:=opt_command h=opt_help -help=opt_help
	if (( $? )) || (( $#opt_help )) || (( ! $#opt_agent )) || (( ! $#opt_worktree )); then
		fork-agent-help
		return 1
	fi

	local agent="${opt_agent[-1]}" worktree_name="${opt_worktree[-1]}"
	local -a command_arg
	(( $#opt_command )) && command_arg=("${opt_command[-1]}")

	if [ "$HERDR_ENV" = "1" ] && [ -n "$HERDR_WORKSPACE_ID" ]; then
		_fork-agent-herdr "$agent" "$worktree_name" "${command_arg[@]}"
	elif [ -n "$TMUX" ]; then
		_fork-agent-tmux "$agent" "$worktree_name" "${command_arg[@]}"
	else
		echo "fork-agent: must be run from inside a multiplexer (tmux or herdr)" >&2
		return 1
	fi
}

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

	local pane
	pane="$(command herdr worktree create --workspace "$HERDR_WORKSPACE_ID" --branch "$worktree_name" --label "$worktree_name" --no-focus 2>/dev/null | jq -r '.result.root_pane.pane_id // empty')"
	if [ -z "$pane" ]; then
		echo "fork-agent: failed to create worktree $worktree_name" >&2
		return 1
	fi

	local -a start_args=(agent start "$worktree_name" --kind "$agent" --pane "$pane")
	case "$agent" in
		claude) start_args+=(-- -n "$worktree_name") ;;
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
		command herdr agent prompt "$worktree_name" "${command_arg[-1]}" >/dev/null 2>&1
	fi
	return 0
}

function _fork-agent-tmux {
	local agent="$1" worktree_name="$2"
	local -a command_arg=("${@:3}")

	command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		echo "fork-agent: not inside a git repository" >&2
		return 1
	}

	local repo_root worktree_path
	repo_root="$(command git rev-parse --show-toplevel)"
	worktree_path="$(command dirname "$repo_root")/git-worktrees/$worktree_name"

	if [ -e "$worktree_path" ]; then
		echo "fork-agent: worktree path already exists: $worktree_path" >&2
		return 1
	fi

	command git -C "$repo_root" worktree add "$worktree_path" -b "$worktree_name" >/dev/null 2>&1 || {
		echo "fork-agent: failed to create worktree $worktree_name" >&2
		return 1
	}

	local -a cmd=("$agent")
	case "$agent" in
		claude) cmd+=(-n "$worktree_name") ;;
		copilot) cmd+=(--name "$worktree_name") ;;
	esac
	(( $#command_arg )) && cmd+=("${command_arg[-1]}")

	command tmux new-window -d -n "$worktree_name" -c "$worktree_path" -- "${cmd[@]}"
}

function fork-agent-help {
	cat <<-EOF
	Usage: fork-agent -a <agent> -w <worktree_name> [-c "<command>"]

	  Fork the current git project into a new worktree and start <agent>
	  inside it. Detects which multiplexer is active and behaves accordingly
	  (herdr is checked first, then tmux):

	    herdr   Active when \$HERDR_ENV=1 and \$HERDR_WORKSPACE_ID is set (i.e.
	            run from inside an active herdr pane sitting in the project
	            you want to fork; the repo is resolved from that workspace).
	            The worktree is created and managed by herdr (\`herdr worktree
	            create\`); <command>, if given, is sent via \`herdr agent
	            prompt\` once the agent is running.

	    tmux    Active when \$TMUX is set. Creates a plain git worktree at
	            <parent-of-repo>/git-worktrees/<worktree_name> and opens it in
	            a new tmux window (reachable via prefix+<number> or
	            prefix+w), without switching focus to it. <command>, if
	            given, is passed as a trailing argument to <agent> at launch
	            (e.g. \`claude -n name "<command>"\`) instead of being sent
	            afterwards.

	  If neither multiplexer is detected, prints an error and exits.

	  -a <agent>          Agent kind to launch. Under herdr this is passed to
	                      \`herdr agent start --kind\` (run \`herdr agent start
	                      --help\` for the supported list, e.g. claude, codex,
	                      copilot, gemini); under tmux it's run directly as a
	                      shell command. When <agent> is "claude" or
	                      "copilot" it is also given a matching session/
	                      display name (-n / --name).
	  -w <worktree_name>  Name for the new git branch/worktree, also used as
	                      the tmux window name or herdr agent name.
	  -c <command>        Optional initial prompt for the agent. Delivery
	                      mechanism differs by multiplexer, see above.
	  -h, --help          Show this help.
	EOF
}
