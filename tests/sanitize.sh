#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

HELPER="$MODULES/zsh/.config/zsh/functions/helpers/_agent-sanitize-name.zsh"
long=$(printf 'a%.0s' {1..40})

sanitize() {
	# shellcheck disable=SC2016
	zsh -f -c 'source "$1"; _agent-sanitize-name "$2"' _ "$HELPER" "$1"
}

check() {
	local result
	result=$(sanitize "$1")
	assert_eq "sanitize '$1'" "$2" "$result"
	assert_true "'$result' fits herdr's name rule" grep -Eq '^[a-z][a-z0-9_-]{0,31}$' <<<"$result"
}

check myrepo myrepo
check MyRepo myrepo
check foo.bar_baz-1 foo-bar_baz-1
check "foo bar/baz" foo-bar-baz
check 123abc abc
check --x x
check _x x
check "$long" "${long:0:32}"
check "12${long}" "${long:0:32}"
check "" agent
check 123 agent
check ... agent
