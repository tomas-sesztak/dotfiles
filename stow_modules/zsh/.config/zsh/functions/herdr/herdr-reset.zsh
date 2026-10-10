function herdr-reset {
	local -a opt_yes opt_help
	zparseopts -D -E -- y=opt_yes -yes=opt_yes h=opt_help -help=opt_help
	if (( $? )) || (( $#opt_help )) || (( $# )); then
		herdr-reset-help
		return 1
	fi

	command -v herdr >/dev/null 2>&1 || {
		echo "herdr-reset: herdr not found in PATH" >&2
		return 1
	}
	command -v jq >/dev/null 2>&1 || {
		echo "herdr-reset: jq not found in PATH" >&2
		return 1
	}

	if [ "$(command herdr status --json 2>/dev/null | jq -r '.server.running // false')" != "true" ]; then
		setsid command herdr server >/dev/null 2>&1 </dev/null &
		disown

		local tries=0
		until [ "$(command herdr status --json 2>/dev/null | jq -r '.server.running // false')" = "true" ]; do
			(( tries++ >= 50 )) && {
				echo "herdr-reset: timed out waiting for herdr server to start" >&2
				return 1
			}
			sleep 0.2
		done
	fi

	local -a entries
	entries=("${(@f)$(command herdr workspace list 2>/dev/null | jq -r '.result.workspaces[] | "\(.workspace_id)\t\(.label) (\(.agent_status))"')}")
	entries=("${(@)entries:#}")

	if (( $#entries )) && (( ! $#opt_yes )); then
		local entry
		for entry in "${entries[@]}"; do
			echo "  ${entry#*$'\t'}"
		done
		read -q "?Close ${#entries} workspaces? [y/N] " || {
			echo
			return 1
		}
		echo
	fi

	command herdr workspace create --cwd "$HOME" --focus >/dev/null 2>&1 || {
		echo "herdr-reset: failed to create new workspace" >&2
		return 1
	}

	# Close own workspace last; it kills this shell.
	local workspace_id close_self
	for entry in "${entries[@]}"; do
		workspace_id="${entry%%$'\t'*}"
		if [ "$workspace_id" = "$HERDR_WORKSPACE_ID" ]; then
			close_self=1
			continue
		fi
		command herdr workspace close "$workspace_id" >/dev/null 2>&1
	done
	[ -n "$close_self" ] && command herdr workspace close "$HERDR_WORKSPACE_ID" >/dev/null 2>&1
	return 0
}

function herdr-reset-help {
	cat <<-EOF
	Usage: herdr-reset [-y]

	  Close every herdr workspace and open a single fresh one in \$HOME,
	  like starting a new session. Running agents are killed; git worktree
	  checkouts on disk are left untouched. Starts the herdr server if it
	  is not running. The calling workspace is closed last.

	  -y, --yes    Skip the confirmation prompt.
	  -h, --help   Show this help.
	EOF
}
