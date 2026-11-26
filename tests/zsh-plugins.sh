#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

FUNCS="$MODULES/zsh/.config/zsh/functions"
HIST="$SANDBOX/history"
echo 'echo hello-suggest' >"$HIST"
export TERM=xterm-256color

# drives an interactive zsh in a pty; each argument is typed after a short pause
# shellcheck disable=SC2016
drive() {
	limited zsh -f -c '
		zmodload zsh/zpty
		zpty sh "zsh -f -i"
		zpty -w sh "PS1=\"> \"; source $1/autosuggestions.zsh; source $1/late/syntax.zsh; fc -R $2"
		shift 2
		sleep 1
		for keys; do zpty -wn sh "$keys"; sleep 0.3; done
		zpty -w sh $'"'"'\C-uexit'"'"'; sleep 0.3
		while zpty -r -t sh chunk 2>/dev/null; do print -rn -- "$chunk"; done
		zpty -d sh
	' _ "$FUNCS" "$HIST" "$@"
}

out=$(drive 'echo h')
assert_contains "ghost text is grey" $'\e[90m' "$out"
assert_contains "ghost text shown" 'hello-suggest' "$out"

out=$(drive 'echo h' $'\e[C\n')
assert_contains "right arrow accepts suggestion" $'\nhello-suggest' "$out"

out=$(drive lsxq)
assert_contains "unknown command is red" $'\e[31ml' "$out"

out=$(drive 'echo')
assert_contains "known command is green" $'\e[32me' "$out"
