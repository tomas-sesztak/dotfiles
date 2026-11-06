#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

Z="$MODULES/zsh/.config/zsh/functions"
PROJECT="$SANDBOX/proj"
REPO="$PROJECT/repo"
WORKTREES="$PROJECT/git-worktrees"

zfn() {
	# shellcheck disable=SC2016
	zsh -f -c '
		base=$1; shift
		for f in $base/helpers/*.zsh $base/fork-agent.zsh $base/tmux/fork-agent-tmux.zsh \
			$base/cleanup-agents.zsh $base/tmux/cleanup-agents-tmux.zsh; do
			source $f
		done
		"$@"' _ "$Z" "$@"
}

in_repo() {
	(cd "$REPO" && zfn "$@")
}

has_window() {
	tmux list-windows -F '#W' | grep -qx "$1"
}

agent_options() {
	tmux display -p -t "$1" '#{@agent}|#{@agent_name}|#{@agent_state}'
}

pane_idle_in_shell() {
	[[ "$(tmux display -p -t "test:$1" '#{pane_current_command}')" == sh ]]
}

mark_agent() {
	tmux set -p -t "test:$1" @agent_cmd sh \; set -p -t "test:$1" @agent_state "$2"
}

fork() {
	in_repo fork-agent -a true -w "$1" >/dev/null
	wait_for "$1 pane ready" pane_idle_in_shell "$1"
}

fork_outside_repo() {
	(cd "$SANDBOX" && zfn fork-agent -a true -w nope)
}

fork_without_multiplexer() {
	(
		unset TMUX
		in_repo fork-agent -a true -w nope
	)
}

deploy_sandbox
start_tmux

assert_status "tmux.conf loads" 0 tmux source-file "$HOME/.tmux.conf"
keys=$(tmux list-keys)
assert_contains "core binding" "resize-pane -Z" "$keys"
assert_contains "sidebar plugin binding" "agent-sidebar-toggle" "$keys"
assert_contains "picker binding" "agent-picker" "$keys"
assert_contains "vim-integration binding" "select-pane -L" "$keys"
assert_eq "pane border option" double "$(tmux show-options -gv pane-border-lines)"

pane=$(tmux display -p -t test '#{pane_id}')
report="$HOME/.tmux/scripts/agent-report"
TMUX_PANE=$pane "$report" claude working named
assert_eq "agent-report sets options" "claude|named|working" "$(agent_options "$pane")"
TMUX_PANE=$pane "$report" claude "done"
assert_eq "done stays done when not visible, name kept" "claude|named|done" "$(agent_options "$pane")"
assert_not_contains "agent_cmd recorded" "||" "$(tmux display -p -t "$pane" '|#{@agent_cmd}|')"
TMUX_PANE=$pane "$report" claude clear
assert_eq "agent-report clears options" "||" "$(agent_options "$pane")"
assert_status "agent-report without pane is a no-op" 0 "$report" claude working

mkdir -p "$REPO"
git -C "$REPO" init -q -b main
git -C "$REPO" commit -q --allow-empty -m init
REPO_KEY=$(git -C "$REPO" rev-parse --path-format=absolute --git-common-dir)

fork wt-a
assert_true "fork creates the worktree" test -e "$WORKTREES/wt-a/.git"
assert_eq "fork creates the branch" wt-a "$(git -C "$WORKTREES/wt-a" branch --show-current)"
assert_true "fork opens the window" has_window wt-a
assert_eq "fork tags @repo" "$REPO_KEY" "$(tmux show-options -wqv -t test:wt-a @repo)"
assert_not_contains "fork does not switch focus" wt-a "$(tmux display -p -t test '#W')"
assert_contains "fork starts the agent" true "$(tmux capture-pane -p -t test:wt-a)"

assert_status "fork refuses an existing path" 1 in_repo fork-agent -a true -w wt-a
assert_status "fork needs -w" 1 in_repo fork-agent -a true
assert_status "fork outside a repo" 1 fork_outside_repo
assert_status "fork outside a multiplexer" 1 fork_without_multiplexer

output=$(in_repo cleanup-agents -n 2>&1)
assert_contains "dry run reports" "[dry-run] would close window wt-a" "$output"
assert_true "dry run keeps the window" has_window wt-a
assert_true "dry run keeps the worktree" test -d "$WORKTREES/wt-a"

touch "$WORKTREES/wt-a/untracked"
output=$(in_repo cleanup-agents 2>&1)
assert_contains "untracked file blocks cleanup" "uncommitted changes" "$output"
assert_true "dirty worktree kept" test -d "$WORKTREES/wt-a"
assert_true "dirty window kept" has_window wt-a
mv "$WORKTREES/wt-a/untracked" "$SANDBOX/"

mark_agent wt-a working
in_repo cleanup-agents >/dev/null 2>&1
assert_true "busy worktree kept" test -d "$WORKTREES/wt-a"
assert_true "busy window kept" has_window wt-a

tmux new-window -d -n repo -c "$REPO"
mark_agent wt-a idle
in_repo cleanup-agents >/dev/null 2>&1
assert_true "idle worktree removed" test ! -e "$WORKTREES/wt-a"
if has_window wt-a; then fail "idle window should close"; else pass; fi
assert_true "main checkout kept" test -d "$REPO/.git"
assert_true "main checkout window kept" has_window repo
assert_eq "only the main worktree remains" 1 "$(git -C "$REPO" worktree list | wc -l | tr -d ' ')"
