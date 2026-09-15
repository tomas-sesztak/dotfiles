function _cleanup-agents-tmux {
	local dry_run="$1"

	command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		echo "cleanup-agents: not inside a git repository" >&2
		return 1
	}

	local repo_root
	repo_root="$(command git rev-parse --show-toplevel)"

	local -a lines worktrees
	lines=("${(@f)$(command git -C "$repo_root" worktree list --porcelain)}")
	local line wt_path first=1
	for line in "${lines[@]}"; do
		case "$line" in
			worktree\ *)
				wt_path="${line#worktree }"
				if (( first )); then
					first=0
				else
					worktrees+=("$wt_path")
				fi
				;;
		esac
	done

	local name pane_cmds
	for wt_path in "${worktrees[@]}"; do
		name="$(command basename "$wt_path")"
		command tmux list-windows -F '#W' | grep -qx "$name" || continue

		pane_cmds="$(command tmux list-panes -t "$name" -F '#{pane_current_command}')"
		print -r -- "$pane_cmds" | grep -qxE 'claude|copilot' && continue

		if [ -n "$(command git -C "$wt_path" status --porcelain)" ]; then
			echo "cleanup-agents: skipping $name, worktree has uncommitted changes" >&2
			continue
		fi

		if [ -n "$dry_run" ]; then
			echo "cleanup-agents: [dry-run] would close window $name and remove worktree $wt_path"
			continue
		fi

		command tmux kill-window -t "$name"
		command git -C "$repo_root" worktree remove "$wt_path"
	done
}
