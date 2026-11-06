#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

deploy_sandbox
cd "$SANDBOX" || exit 1

assert_no_errors() {
	local name=$1 output=$2 pattern
	for pattern in E5113 "stack traceback" "Error detected" "Error in"; do
		assert_not_contains "$name: $pattern" "$pattern" "$output"
	done
}

output=$(limited nvim --headless \
	+'lua print("core=" .. tostring(package.loaded["tomas-sesztak.core"] ~= nil))' \
	+'lua print("plugins=" .. tostring(package.loaded["tomas-sesztak.plugins"] ~= nil))' \
	+qa 2>&1)
assert_eq "nvim exits cleanly" 0 $?
assert_contains "nvim loads core" "core=true" "$output"
assert_contains "nvim loads plugins" "plugins=true" "$output"
assert_no_errors nvim "$output"

log="$SANDBOX/vim.log"
limited vim -u NONE -N -es \
	-c "redir! > $log" \
	-c 'source ~/.vimrc' \
	-c "silent echo 'tmuxmove=' . exists('*TmuxMove')" \
	-c 'redir END' \
	-c 'qa!'
assert_eq "vim exits cleanly" 0 $?
output=$(cat "$log")
assert_contains "vim sources tmux.vim" "tmuxmove=1" "$output"
assert_no_errors vim "$output"
