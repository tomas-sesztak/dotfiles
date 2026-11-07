#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

SETUP="$REPO_ROOT/setup.sh"

fresh_home() {
	HOME="$(mktemp -d "$SANDBOX/home.XXXXXX")"
}

links_to() {
	[[ -L "$1" && "$1" -ef "$2" ]]
}

absent() {
	[[ ! -e "$1" && ! -L "$1" ]]
}

assert_deployed() {
	assert_true ".vimrc" links_to "$HOME/.vimrc" "$MODULES/vim/.vimrc"
	assert_true ".vim" links_to "$HOME/.vim" "$MODULES/vim/.vim"
	assert_true ".bashrc" links_to "$HOME/.bashrc" "$MODULES/bash/.bashrc"
	assert_true ".tmux" links_to "$HOME/.tmux" "$MODULES/tmux/.tmux"
	assert_true ".copilot" links_to "$HOME/.copilot" "$MODULES/copilot/.copilot"
	assert_true ".claude" links_to "$HOME/.claude" "$MODULES/claude/.claude"
	assert_true ".Brewfile_dotfiles" links_to "$HOME/.Brewfile_dotfiles" "$MODULES/homebrew/.Brewfile_dotfiles"
	assert_true ".config/nvim" links_to "$HOME/.config/nvim" "$MODULES/nvim/.config/nvim"
	assert_true ".config/herdr" links_to "$HOME/.config/herdr" "$MODULES/herdr/.config/herdr"
	# stow folds these at ~/.config/zsh, so the link sits one level up
	assert_true ".config/zsh/functions" test "$HOME/.config/zsh/functions" -ef "$MODULES/zsh/.config/zsh/functions"
	assert_true ".config/zsh/completions" test "$HOME/.config/zsh/completions" -ef "$MODULES/zsh/.config/zsh/completions"
}

source_lines() {
	grep -cF "$2" "$1"
}

ZSH_INIT="functions/init/init.zsh"
TMUX_INIT=".tmux/tmux.conf"

fresh_home
assert_status "deploy" 0 "$SETUP" deploy
assert_deployed
assert_true "AGENTS.md not deployed" absent "$HOME/AGENTS.md"
assert_eq ".zshrc source line" 1 "$(source_lines "$HOME/.zshrc" "$ZSH_INIT")"
assert_eq ".tmux.conf source line" 1 "$(source_lines "$HOME/.tmux.conf" "$TMUX_INIT")"

assert_status "redeploy" 0 "$SETUP" deploy
assert_deployed
assert_eq "redeploy keeps one .zshrc line" 1 "$(source_lines "$HOME/.zshrc" "$ZSH_INIT")"
assert_eq "redeploy keeps one .tmux.conf line" 1 "$(source_lines "$HOME/.tmux.conf" "$TMUX_INIT")"

assert_status "undeploy" 0 "$SETUP" undeploy
for path in .vimrc .vim .bashrc .tmux .copilot .claude .Brewfile_dotfiles .config/nvim .config/herdr .config/zsh/functions; do
	assert_true "undeploy removes $path" absent "$HOME/$path"
done

fresh_home
printf 'export KEEP=1\n' >"$HOME/.zshrc"
printf 'set -g mouse on\n' >"$HOME/.tmux.conf"
"$SETUP" deploy >/dev/null
assert_contains "keeps .zshrc content" "export KEEP=1" "$(cat "$HOME/.zshrc")"
assert_contains "keeps .tmux.conf content" "set -g mouse on" "$(cat "$HOME/.tmux.conf")"
assert_eq "appends to .zshrc" 1 "$(source_lines "$HOME/.zshrc" "$ZSH_INIT")"
assert_eq "appends to .tmux.conf" 1 "$(source_lines "$HOME/.tmux.conf" "$TMUX_INIT")"

fresh_home
printf 'linked\n' >"$HOME/old-target"
ln -s "$HOME/old-target" "$HOME/.zshrc"
ln -s "$HOME/old-target" "$HOME/.tmux.conf"
"$SETUP" deploy >/dev/null
assert_true "stale .zshrc link replaced" test ! -L "$HOME/.zshrc"
assert_true "stale .tmux.conf link replaced" test ! -L "$HOME/.tmux.conf"
assert_eq "stale link target untouched" linked "$(cat "$HOME/old-target")"
assert_eq "new .zshrc has source line" 1 "$(source_lines "$HOME/.zshrc" "$ZSH_INIT")"

fresh_home
"$SETUP" deploy --no-claude >/dev/null
assert_true "--no-claude skips ~/.claude" absent "$HOME/.claude"
assert_true "--no-claude deploys the rest" links_to "$HOME/.vimrc" "$MODULES/vim/.vimrc"

fresh_home
"$SETUP" deploy >/dev/null
"$SETUP" undeploy --no-claude >/dev/null
assert_true "undeploy --no-claude keeps ~/.claude" links_to "$HOME/.claude" "$MODULES/claude/.claude"
assert_true "undeploy --no-claude removes the rest" absent "$HOME/.vimrc"

fresh_home
printf 'mine\n' >"$HOME/.vimrc"
assert_status "conflict fails" 1 "$SETUP" deploy
assert_eq "conflict keeps the real file" mine "$(cat "$HOME/.vimrc")"

fresh_home
assert_status "no arguments" 1 "$SETUP"
assert_status "unknown argument" 1 "$SETUP" bogus
assert_status "two actions" 1 "$SETUP" deploy undeploy
assert_true "bad arguments change nothing" absent "$HOME/.vimrc"

path_dir="$SANDBOX/nostow"
mkdir "$path_dir"
for tool in bash dirname basename; do
	ln -s "$(command -v "$tool")" "$path_dir/$tool"
done
output=$(PATH="$path_dir" "$SETUP" deploy 2>&1)
assert_contains "missing stow" "GNU Stow is not installed" "$output"
