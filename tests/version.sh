#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

SCRIPT="$MODULES/tmux/.tmux/scripts/dotfiles-version"
export DOTFILES_REPO="$SANDBOX/repo"

git init -q -b main "$DOTFILES_REPO"
git -C "$DOTFILES_REPO" commit -q --allow-empty -m one
assert_eq "untagged: no output" "" "$("$SCRIPT")"
assert_status "untagged: exit 0" 0 "$SCRIPT"

git -C "$DOTFILES_REPO" tag -a v1.2.3 -m v1.2.3
assert_eq "on tag" "v1.2.3 " "$("$SCRIPT")"

git -C "$DOTFILES_REPO" commit -q --allow-empty -m two
out=$("$SCRIPT")
assert_eq "past tag" "v1.2.3-1-g$(git -C "$DOTFILES_REPO" rev-parse --short HEAD) " "$out"
assert_not_contains "no style, inherits clock style" "#[" "$out"

DOTFILES_REPO="$SANDBOX/nope" assert_status "not a repo: exit 0" 0 "$SCRIPT"
