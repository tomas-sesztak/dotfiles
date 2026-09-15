function cleanup-agents {
	local -a opt_dry_run opt_help
	zparseopts -D -E -- n=opt_dry_run -dry-run=opt_dry_run h=opt_help -help=opt_help
	if (( $? )) || (( $#opt_help )); then
		cleanup-agents-help
		return 1
	fi

	local -a dry_run_arg
	(( $#opt_dry_run )) && dry_run_arg=(1)

	if [ "$HERDR_ENV" = "1" ] && [ -n "$HERDR_WORKSPACE_ID" ]; then
		_cleanup-agents-herdr "${dry_run_arg[@]}"
	elif [ -n "$TMUX" ]; then
		_cleanup-agents-tmux "${dry_run_arg[@]}"
	else
		echo "cleanup-agents: must be run from inside a multiplexer (tmux or herdr)" >&2
		return 1
	fi
}

function cleanup-agents-help {
	cat <<-EOF
	Usage: cleanup-agents [-n]

	  Close windows/workspaces for agents running in git worktrees of the
	  current repo (never the main checkout) that are done with their task
	  and have no uncommitted changes (untracked files count as dirty too).
	  Closing also removes the git worktree checkout; the branch itself is
	  left behind. Detects which multiplexer is active and behaves
	  accordingly (herdr is checked first, then tmux):

	    herdr   Active when \$HERDR_ENV=1 and \$HERDR_WORKSPACE_ID is set. Uses
	            \`herdr agent list\`'s agent_status to find worktree agents
	            that are idle or done, then \`herdr worktree remove\` to close
	            the workspace and delete the checkout in one step.

	    tmux    Active when \$TMUX is set. Plain tmux has no idle/working
	            signal, so a window is only closable when none of its panes
	            are still running \`claude\` or \`copilot\` (the agent process
	            already exited but the window is still open, e.g. a shell
	            pane left over from a split). A window whose agent is idle
	            but still running is left alone under tmux.

	  If neither multiplexer is detected, prints an error and exits.

	  -n, --dry-run   Print what would be closed/removed without doing it.
	  -h, --help      Show this help.
	EOF
}
