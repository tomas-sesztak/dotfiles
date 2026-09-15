function init-agents {
	local -a opt_agent opt_path opt_help
	zparseopts -D -E -- a:=opt_agent p:=opt_path h=opt_help -help=opt_help
	if (( $? )) || (( $#opt_help )) || (( ! $#opt_agent )) || (( ! $#opt_path )); then
		init-agents-help
		return 1
	fi

	local agent="${opt_agent[-1]}" repo_path="${opt_path[-1]}"
	if [ ! -d "$repo_path" ]; then
		echo "init-agents: not a directory: $repo_path" >&2
		return 1
	fi

	if [ "$HERDR_ENV" = "1" ] && [ -n "$HERDR_WORKSPACE_ID" ]; then
		_init-agents-herdr "$agent" "$repo_path"
	elif [ -n "$TMUX" ]; then
		_init-agents-tmux "$agent" "$repo_path"
	else
		echo "init-agents: must be run from inside a multiplexer (tmux or herdr)" >&2
		return 1
	fi
}

function init-agents-help {
	cat <<-EOF
	Usage: init-agents -a <agent> -p <path>

	  For each top-level git repository directory under <path>, ensure a
	  window/workspace named after that directory exists in the current
	  multiplexer session. If missing, create it with a horizontal split:
	  <agent> running in the top pane (cwd set to the repo), and a blank
	  interactive shell (same cwd) in the bottom pane for manual commands.
	  Entries that already exist are left untouched.

	  Detects which multiplexer is active and behaves accordingly (herdr is
	  checked first, then tmux):

	    herdr   Active when \$HERDR_ENV=1 and \$HERDR_WORKSPACE_ID is set (i.e.
	            run from inside an active herdr pane). Automatically starts a
	            herdr server in the background if one isn't already running.
	            Local machine only, no remote support. <agent> is passed to
	            \`herdr agent start --kind\` (run \`herdr agent start --help\`
	            for the supported list, e.g. claude, codex, copilot, gemini).

	    tmux    Active when \$TMUX is set (i.e. run from inside an active tmux
	            session). <agent> is run directly as a shell command (e.g.
	            claude, copilot, aider).

	  If neither is detected, prints an error and exits.

	  In both modes, when <agent> is "claude" or "copilot" it is also given a
	  matching session/display name (-n / --name).

	  -a <agent>   Command/agent kind to launch.
	  -p <path>    Directory whose top-level git repos should get windows.
	  -h, --help   Show this help.
	EOF
}
