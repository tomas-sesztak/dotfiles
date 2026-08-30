function tmux-init-agents {
	if [ -z "$TMUX" ]; then
		echo "tmux-init-agents: must be run from inside a tmux session" >&2
		return 1
	fi

	local -a opt_agent opt_path opt_help
	zparseopts -D -E -- a:=opt_agent p:=opt_path h=opt_help -help=opt_help
	if (( $? )) || (( $#opt_help )) || (( ! $#opt_agent )) || (( ! $#opt_path )); then
		tmux-init-agents-help
		return 1
	fi

	local agent="${opt_agent[-1]}" repo_path="${opt_path[-1]}"
	if [ ! -d "$repo_path" ]; then
		echo "tmux-init-agents: not a directory: $repo_path" >&2
		return 1
	fi

	local dir name
	local -a cmd

	for dir in "$repo_path"/*/; do
		[ -e "${dir}.git" ] || continue
		name="$(basename "$dir")"
		command tmux list-windows -F '#W' | grep -qx "$name" && continue

		cmd=("$agent")
		case "$agent" in
			claude) cmd+=(-n "$name") ;;
			copilot) cmd+=(--name "$name") ;;
		esac
		command tmux new-window -d -n "$name" -c "$dir" -- "${cmd[@]}"
	done
}

function tmux-init-agents-help {
	cat <<-EOF
	Usage: tmux-init-agents -a <agent> -p <path>

	  For each top-level git repository directory under <path>, ensure a tmux
	  window named after that directory exists in the current tmux session.
	  If missing, create it and launch <agent> inside it (cwd set to the
	  repo). Windows that already exist are left untouched.

	  -a <agent>   Command to launch (e.g. claude, copilot, aider). When
	               agent is "claude" or "copilot", it is also given a
	               matching session/display name (-n / --name).
	  -p <path>    Directory whose top-level git repos should get windows.
	  -h, --help   Show this help.

	Must be run from inside an active tmux session.
	EOF
}
