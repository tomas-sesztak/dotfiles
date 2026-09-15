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

	local agent_name
	agent_name="$(_agent-sanitize-name "$worktree_name")"

	local -a cmd=("$agent")
	case "$agent" in
		claude) cmd+=(-n "$agent_name") ;;
		copilot) cmd+=(--name "$agent_name") ;;
	esac
	(( $#command_arg )) && cmd+=("${command_arg[-1]}")

	command tmux new-window -d -n "$worktree_name" -c "$worktree_path" -- "${cmd[@]}"
}
