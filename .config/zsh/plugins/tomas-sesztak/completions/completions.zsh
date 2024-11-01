# list of managed completions
export COMPLETIONS_MANAGED=(
	"gh completion -s zsh"
	"oc completion zsh"
)

# where custom completion lives
export COMPLETIONS_DIR="${HOME}/.config/zsh/completion"

# add custom completion directory to fpath
export fpath=( "$COMPLETIONS_DIR" ${fpath[@]} )

# nice completion menu
zstyle ':completion:*' menu select
