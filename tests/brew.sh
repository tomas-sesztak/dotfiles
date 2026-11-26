#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

BREW_ZSH="$MODULES/zsh/.config/zsh/functions/brew.zsh"
LOG="$SANDBOX/brew.log"
export TMPDIR="$SANDBOX/tmp" BREW_LOG="$LOG"
mkdir -p "$SANDBOX/bin" "$TMPDIR"

cat >"$SANDBOX/bin/brew" <<'EOF'
#!/usr/bin/env bash
echo "${*:1:2}" >>"$BREW_LOG"
[[ "$1" == update && -n "${FAIL_UPDATE:-}" ]] && exit 1
[[ "$1 $2" == "bundle install" && -n "${FAIL_INSTALL:-}" ]] && exit 1
exit 0
EOF
chmod +x "$SANDBOX/bin/brew"
export PATH="$SANDBOX/bin:$PATH"

printf 'brew "jq"\ntap "a/b"\n' >"$HOME/.Brewfile_dotfiles"

run() {
	: >"$LOG"
	# shellcheck disable=SC2016
	env "$@" zsh -f -c 'source "$1"; brew_update' _ "$BREW_ZSH" >/dev/null 2>&1
}

all_steps="update
bundle install
bundle cleanup
upgrade
autoremove
cleanup"

run
assert_eq "success: status" 0 $?
assert_eq "success: all steps" "$all_steps" "$(cat "$LOG")"

run FAIL_INSTALL=1
assert_eq "install failure: status" 1 $?
assert_eq "install failure: cleanup still runs" "$all_steps" "$(cat "$LOG")"

run FAIL_UPDATE=1
assert_eq "update failure: status" 1 $?
assert_eq "update failure: stops early" "update" "$(cat "$LOG")"

assert_eq "temp Brewfile removed" "" "$(ls -A "$TMPDIR")"
