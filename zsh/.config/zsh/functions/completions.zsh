# list of managed completions
export COMPLETIONS_MANAGED=(
  "gh completion -s zsh"
  "oc completion zsh"
)

# where custom completion lives
export COMPLETIONS_DIR="${HOME}/.config/zsh/completions"

# add custom completion directory to fpath
export fpath=( "$COMPLETIONS_DIR" ${fpath[@]} )

function clean_completions_dir() {
  if [[ ! -d "$COMPLETIONS_DIR" ]]; then
      echo "Error: Directory '$COMPLETIONS_DIR' not found."
      return 1
  fi

  echo "Listing files in '$COMPLETIONS_DIR':"
  # Use find to list all regular files in the directory recursively
  find "$COMPLETIONS_DIR" -type f

  # Ask for confirmation using zsh's built-in VFS confirmation prompt (y/n/a/q)
  echo "\nDo you want to permanently remove ALL listed files?"
  read -q "choice? (y/n) "

  if [[ "$choice" == "y" ]]; then
      echo "\nRemoving files..."
      # Use find with -delete to efficiently remove files found
      find "$COMPLETIONS_DIR" -type f -delete
      echo "Removal complete."
  else
      echo "\nOperation cancelled."
  fi
}

function generate_completions() {
  clean_completions_dir
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
