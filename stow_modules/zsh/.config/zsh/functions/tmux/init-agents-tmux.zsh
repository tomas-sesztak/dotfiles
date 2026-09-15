function _init-agents-tmux {
	local agent="$1" repo_path="$2"
	local dir name agent_name
	local -a cmd

	for dir in "$repo_path"/*/; do
		[ -e "${dir}.git" ] || continue
		name="$(basename "$dir")"
		command tmux list-windows -F '#W' | grep -qx "$name" && continue

		agent_name="$(_agent-sanitize-name "$name")"
		cmd=("$agent")
		case "$agent" in
			claude) cmd+=(-n "$agent_name") ;;
			copilot) cmd+=(--name "$agent_name") ;;
		esac
		local window_id
		window_id="$(command tmux new-window -d -n "$name" -c "$dir" -P -F '#{window_id}' -- "${cmd[@]}")"
		command tmux split-window -d -v -t "$window_id" -c "$dir"
	done
}
