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

	local dir name agent_name pane
	local -a agent_args
	for dir in "$repo_path"/*/; do
		[ -e "${dir}.git" ] || continue
		name="$(basename "$dir")"
		(( ${existing[(Ie)$name]} )) && continue

		agent_name="$(_agent-sanitize-name "$name")"

		pane="$(command herdr workspace create --cwd "$dir" --label "$name" --no-focus 2>/dev/null | jq -r '.result.root_pane.pane_id // empty')"
		if [ -z "$pane" ]; then
			echo "init-agents: failed to create workspace for $name" >&2
			continue
		fi

		command herdr pane split --pane "$pane" --direction down --cwd "$dir" --no-focus >/dev/null 2>&1

		agent_args=()
		case "$agent" in
			claude) agent_args=(-n "$agent_name") ;;
			copilot) agent_args=(--name "$agent_name") ;;
		esac

		local tries=0
		until command herdr agent get "$agent_name" >/dev/null 2>&1; do
			command herdr agent start "$agent_name" --kind "$agent" --pane "$pane" -- "${agent_args[@]}" >/dev/null 2>&1
			(( tries++ >= 10 )) && {
				echo "init-agents: failed to start agent for $name" >&2
				break
			}
			sleep 0.3
		done
	done
}
