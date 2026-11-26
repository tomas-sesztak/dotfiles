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

status_of() {
	tmux display -p -t "test:$1" "$(tmux show -gv window-status-format)"
}
tmux new-window -d -n plain
wait_for "plain pane ready" pane_idle_in_shell plain
assert_eq "status hides window without agent" "" "$(status_of plain)"
mark_agent plain "done"
assert_contains "status shows window with live agent" plain "$(status_of plain)"
tmux set -p -t test:plain @agent_cmd node
assert_eq "status hides stale agent" "" "$(status_of plain)"
tmux kill-window -t test:plain
assert_eq "s restores session chooser" "choose-tree -Zs" "$(tmux list-keys -T prefix s | sed 's/.* s *//')"

# fzf stub: each call consumes the next "<exit code>|<line>|<line>…" from $FZF_REPLIES
mkdir -p "$SANDBOX/bin"
cat >"$SANDBOX/bin/fzf" <<'STUB'
#!/usr/bin/env bash
cat >/dev/null
n=$(($(cat "$FZF_CALLS" 2>/dev/null || echo 0) + 1))
echo "$n" >"$FZF_CALLS"
IFS='|' read -ra reply <<<"$(sed -n "${n}p" "$FZF_REPLIES")"
printf '%s\n' "${reply[@]:1}"
exit "${reply[0]}"
STUB
chmod +x "$SANDBOX/bin/fzf"
export FZF_REPLIES="$SANDBOX/fzf-replies" FZF_CALLS="$SANDBOX/fzf-calls"
BASE="$SANDBOX/ws"
mkdir -p "$BASE/cur" "$BASE/sub" "$HOME/x"
switcher() {
	printf '%s\n' "$@" >"$FZF_REPLIES"
	rm -f "$FZF_CALLS"
	PATH="$SANDBOX/bin:$PATH" "$HOME/.tmux/scripts/window-switcher" "$BASE/cur"
}
window_dir() {
	tmux display -p -t "test:$1" '#{pane_current_path}'
}
window_count() {
	tmux list-windows | wc -l | tr -d ' '
}

assert_contains "switcher binding" "window-switcher" "$keys"
tmux new-window -d -n other
switcher "0|q|$(tmux display -p -t test:other '#{window_index}') other"
assert_eq "switcher selects window" other "$(tmux display -p -t test '#{window_name}')"
switcher "1|w-sub" "0|su|sub"
assert_eq "switcher picks child dir" "$BASE/sub" "$(window_dir w-sub)"
switcher "1|w-base" "0||."
assert_eq "switcher picks parent dir" "$BASE" "$(window_dir w-base)"
switcher "1|w-home" "1|~/x"
assert_eq "switcher resolves ~ path" "$HOME/x" "$(window_dir w-home)"
switcher "0|w-alt" "0|sub"
assert_eq "switcher alt-enter uses typed relative path" "$BASE/sub" "$(window_dir w-alt)"
switcher "1|w-retry" "1|nope" "0||sub"
assert_eq "switcher re-prompts on missing dir" 3 "$(cat "$FZF_CALLS")"
assert_eq "switcher uses dir after re-prompt" "$BASE/sub" "$(window_dir w-retry)"
count=$(window_count)
switcher "130|"
switcher "1|w-esc" "130|"
switcher "1|"
assert_eq "switcher cancel creates nothing" "$count" "$(window_count)"

mkdir -p "$REPO"
git -C "$REPO" init -q -b main
git -C "$REPO" commit -q --allow-empty -m init

fork wt-a
assert_true "fork creates the worktree" test -e "$WORKTREES/wt-a/.git"
assert_eq "fork creates the branch" wt-a "$(git -C "$WORKTREES/wt-a" branch --show-current)"
assert_true "fork opens the window" has_window wt-a
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
