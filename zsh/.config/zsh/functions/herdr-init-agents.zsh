function herdr-init-agents {
	local -a opt_agent opt_path opt_help
	zparseopts -D -E -- a:=opt_agent p:=opt_path h=opt_help -help=opt_help
	if (( $? )) || (( $#opt_help )) || (( ! $#opt_agent )) || (( ! $#opt_path )); then
		herdr-init-agents-help
		return 1
	fi

	local agent="${opt_agent[-1]}" repo_path="${opt_path[-1]}"
	if [ ! -d "$repo_path" ]; then
		echo "herdr-init-agents: not a directory: $repo_path" >&2
		return 1
	fi

	command -v herdr >/dev/null 2>&1 || {
		echo "herdr-init-agents: herdr not found in PATH" >&2
		return 1
	}
	command -v jq >/dev/null 2>&1 || {
		echo "herdr-init-agents: jq not found in PATH" >&2
		return 1
	}

	if [ "$(command herdr status --json 2>/dev/null | jq -r '.server.running // false')" != "true" ]; then
		setsid command herdr server >/dev/null 2>&1 </dev/null &
		disown

		local tries=0
		until [ "$(command herdr status --json 2>/dev/null | jq -r '.server.running // false')" = "true" ]; do
			(( tries++ >= 50 )) && {
				echo "herdr-init-agents: timed out waiting for herdr server to start" >&2
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
			echo "herdr-init-agents: failed to create workspace for $name" >&2
			continue
		fi

		agent_args=()
		case "$agent" in
			claude) agent_args=(-n "$name") ;;
			copilot) agent_args=(--name "$name") ;;
		esac
		command herdr agent start "$name" --kind "$agent" --pane "$pane" -- "${agent_args[@]}" >/dev/null 2>&1
	done
}

function herdr-init-agents-help {
	cat <<-EOF
	Usage: herdr-init-agents -a <agent> -p <path>

	  For each top-level git repository directory under <path>, ensure a herdr
	  workspace named after that directory exists. If missing, create it and
	  start <agent> inside it (cwd set to the repo). Workspaces that already
	  exist are left untouched.

	  Automatically starts a herdr server in the background if one isn't
	  already running. Local machine only, no remote support.

	  -a <agent>   Agent kind to launch (passed to \`herdr agent start --kind\`).
	               Run \`herdr agent start --help\` for the supported list
	               (e.g. claude, codex, copilot, gemini). When agent is
	               "claude" or "copilot", it is also given a matching
	               session/display name (-n / --name).
	  -p <path>    Directory whose top-level git repos should get workspaces.
	  -h, --help   Show this help.
	EOF
}
