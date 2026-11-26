#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

SCRIPT="$MODULES/tmux/.tmux/scripts/dotfiles-update-check"
STAMP="$XDG_CACHE_HOME/dotfiles/last-fetch"
export DOTFILES_REPO="$SANDBOX/local"

git init -q --bare -b main "$SANDBOX/remote.git"
git clone -q "$SANDBOX/remote.git" "$SANDBOX/upstream" 2>/dev/null
git -C "$SANDBOX/upstream" commit -q --allow-empty -m one
git -C "$SANDBOX/upstream" push -q origin main
git clone -q "$SANDBOX/remote.git" "$DOTFILES_REPO"
git -C "$SANDBOX/upstream" commit -q --allow-empty -m two
git -C "$SANDBOX/upstream" push -q origin main

run() { limited "$SCRIPT" 2>&1; }
behind_seen() { [[ "$(run)" == *"dotfiles 1"* ]]; }
fetch_head() { git -C "$DOTFILES_REPO" rev-parse origin/main; }

initial=$(fetch_head)
mkdir -p "$(dirname "$STAMP")" && touch "$STAMP"
assert_eq "fresh stamp: no output" "" "$(run)"
sleep 0.5
assert_eq "fresh stamp: no fetch" "$initial" "$(fetch_head)"

touch -t 200001010000 "$STAMP"
run >/dev/null
assert_true "stale stamp: stamp refreshed" test -n "$(find "$STAMP" -mmin -60)"
wait_for "stale stamp: behind count shown" behind_seen

rm -f "$STAMP"
git -C "$DOTFILES_REPO" pull -q --ff-only
assert_eq "up to date: no output" "" "$(run)"
assert_true "missing stamp: stamp created" test -f "$STAMP"

DOTFILES_REPO="$SANDBOX/nope" assert_status "not a repo: exit 0" 0 "$SCRIPT"
