function _cleanup-agents-herdr {
	local dry_run="$1"

	command -v herdr >/dev/null 2>&1 || {
		echo "cleanup-agents: herdr not found in PATH" >&2
		return 1
	}
	command -v jq >/dev/null 2>&1 || {
		echo "cleanup-agents: jq not found in PATH" >&2
		return 1
	}

	command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		echo "cleanup-agents: not inside a git repository" >&2
		return 1
	}

	local -a entries
	entries=("${(@f)$(command herdr worktree list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null | jq -r '.result.worktrees[] | select(.is_linked_worktree) | "\(.path)\t\(.open_workspace_id // "")"')}")

	local entry wt_path workspace_id agent_status
	for entry in "${entries[@]}"; do
		wt_path="${entry%%$'\t'*}"
		workspace_id="${entry#*$'\t'}"
		[ -z "$workspace_id" ] && continue

		agent_status="$(command herdr agent list 2>/dev/null | jq -r --arg wid "$workspace_id" '.result.agents[] | select(.workspace_id == $wid) | .agent_status')"
		case "$agent_status" in
			idle|done) ;;
			*) continue ;;
		esac

		if [ -n "$(command git -C "$wt_path" status --porcelain)" ]; then
			echo "cleanup-agents: skipping $wt_path, worktree has uncommitted changes" >&2
			continue
		fi

		if [ -n "$dry_run" ]; then
			echo "cleanup-agents: [dry-run] would remove worktree workspace $workspace_id at $wt_path"
			continue
		fi

		command herdr worktree remove --workspace "$workspace_id"
	done
}
