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
