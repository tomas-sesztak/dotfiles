#!/usr/bin/env bash
# Sourced by each test: assertions plus a throwaway HOME, so the real one is never touched.
set -uo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC2034
MODULES="$REPO_ROOT/stow_modules"
TEST_NAME="$(basename "$0" .sh)"
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")"
TMUX_SOCK=""
passes=0
fails=0

export HOME="$SANDBOX/home"
export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state" XDG_CACHE_HOME="$HOME/.cache"
mkdir -p "$HOME"

# a test run from a live session must not reach the real multiplexers
unset TMUX TMUX_PANE HERDR_ENV HERDR_WORKSPACE_ID GIT_DIR GIT_WORK_TREE

export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

_finish() {
	local status=$?
	[[ -n "$TMUX_SOCK" ]] && command tmux -S "$TMUX_SOCK" kill-server 2>/dev/null
	[[ -n "$SANDBOX" && -d "$SANDBOX" ]] && rm -rf -- "$SANDBOX"
	printf '%s: %d passed, %d failed\n' "$TEST_NAME" "$passes" "$fails"
	((status == 0 && fails == 0 && passes > 0)) && exit 0
	exit 1
}
trap _finish EXIT

pass() { passes=$((passes + 1)); }

fail() {
	fails=$((fails + 1))
	printf 'FAIL [%s] %s\n' "$TEST_NAME" "$*" >&2
}

assert_eq() {
	if [[ "$2" == "$3" ]]; then pass; else fail "$1: expected '$2', got '$3'"; fi
}

assert_contains() {
	if [[ "$3" == *"$2"* ]]; then pass; else fail "$1: expected '$2' in '$3'"; fi
}

assert_not_contains() {
	if [[ "$3" != *"$2"* ]]; then pass; else fail "$1: unexpected '$2' in '$3'"; fi
}

# assert_status <name> <expected> <cmd...>
assert_status() {
	local name=$1 expected=$2 actual=0
	shift 2
	"$@" >/dev/null 2>&1 || actual=$?
	assert_eq "$name" "$expected" "$actual"
}

# assert_true <name> <cmd...>
assert_true() {
	local name=$1
	shift
	if "$@"; then pass; else fail "$name"; fi
}

# wait_for <name> <cmd...>: polls for up to 5s
wait_for() {
	local name=$1 _
	shift
	for _ in {1..50}; do
		"$@" && {
			pass
			return 0
		}
		sleep 0.1
	done
	fail "$name: timed out"
	return 1
}

limited() {
	if command -v timeout >/dev/null; then timeout 30 "$@"; else "$@"; fi
}

deploy_sandbox() {
	"$REPO_ROOT/setup.sh" deploy >/dev/null || {
		fail "sandbox deploy failed"
		exit 1
	}
}

# plain `tmux` calls, including those inside repo scripts, now reach only this server
start_tmux() {
	TMUX_SOCK="$SANDBOX/tmux.sock"
	export SHELL=/bin/sh
	command tmux -S "$TMUX_SOCK" -f /dev/null new-session -d -s test -x 120 -y 40 -c "$SANDBOX" || {
		fail "tmux server failed to start"
		exit 1
	}
	export TMUX="$TMUX_SOCK,0,0"
}
