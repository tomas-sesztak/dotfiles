# list of managed completions
export COMPLETIONS_MANAGED=(
  "gh completion -s zsh"
  "oc completion zsh"
)

# where custom completion lives
export COMPLETIONS_DIR="${HOME}/.config/zsh/completions"

# add custom completion directory to fpath
export fpath=( "$COMPLETIONS_DIR" ${fpath[@]} )

function generate_completions() {
	for c ( ${COMPLETIONS_MANAGED[@]} ) {
	  	bin="${c%% *}"
		if ! command -v -- "$bin" >/dev/null 2>&1; then
			echo "${bin} not found"
			continue
		fi
		echo "Generating completion for ${bin}"
		zsh -c "$c" > "${HOME}/.config/zsh/completions/_${bin}"
	}
}

autoload -Uz compinit
compinit

_comp_options+=(globdots)

# Nice tab complete
zmodload -i zsh/complist

zstyle ':completion:*' menu select=1
zstyle ':completion:*' list-rows 0
zstyle ':completion:*' list-grouped rows 99
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
