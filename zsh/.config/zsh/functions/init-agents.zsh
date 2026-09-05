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

function _init-agents-tmux {
	local agent="$1" repo_path="$2"
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

function _init-agents-herdr {
	local agent="$1" repo_path="$2"

	command -v herdr >/dev/null 2>&1 || {
		echo "init-agents: herdr not found in PATH" >&2
		return 1
	}
	command -v jq >/dev/null 2>&1 || {
		echo "init-agents: jq not found in PATH" >&2
		return 1
	}

	if [ "$(command herdr status --json 2>/dev/null | jq -r '.server.running // false')" != "true" ]; then
		setsid command herdr server >/dev/null 2>&1 </dev/null &
		disown

		local tries=0
		until [ "$(command herdr status --json 2>/dev/null | jq -r '.server.running // false')" = "true" ]; do
			(( tries++ >= 50 )) && {
				echo "init-agents: timed out waiting for herdr server to start" >&2
				return 1
			}
			sleep 0.2
		done
	fi

	local -a existing
	existing=("${(@f)$(command herdr workspace list 2>/dev/null | jq -r '.result.workspaces[].label')}")

	local dir name pane
	local -a agent_args
	for dir in "$repo_path"/*/; do
		[ -e "${dir}.git" ] || continue
		name="$(basename "$dir")"
		(( ${existing[(Ie)$name]} )) && continue

		pane="$(command herdr workspace create --cwd "$dir" --label "$name" --no-focus 2>/dev/null | jq -r '.result.root_pane.pane_id // empty')"
		if [ -z "$pane" ]; then
			echo "init-agents: failed to create workspace for $name" >&2
			continue
		fi

		agent_args=()
		case "$agent" in
			claude) agent_args=(-n "$name") ;;
			copilot) agent_args=(--name "$name") ;;
		esac

		local tries=0
		until command herdr agent get "$name" >/dev/null 2>&1; do
			command herdr agent start "$name" --kind "$agent" --pane "$pane" -- "${agent_args[@]}" >/dev/null 2>&1
			(( tries++ >= 10 )) && {
				echo "init-agents: failed to start agent for $name" >&2
				break
			}
			sleep 0.3
		done
	done
}

function init-agents-help {
	cat <<-EOF
	Usage: init-agents -a <agent> -p <path>

	  For each top-level git repository directory under <path>, ensure a
	  window/workspace named after that directory exists in the current
	  multiplexer session. If missing, create it and launch <agent> inside it
	  (cwd set to the repo). Entries that already exist are left untouched.

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
