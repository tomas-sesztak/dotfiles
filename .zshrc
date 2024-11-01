# Add homebrew to PATH
export PATH="/opt/homebrew/bin:${HOME}/.bin:${PATH}"

# Fix modern sed version
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# Add coreutils to PATH
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# Tmux directory for TPM
export TMUX_TPM_DIRECTORY="${HOME}/.config/tmux/plugins/tpm"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Install antigen if not present
function() {
	ANTIGEN_LOCATION="${HOME}/.config/zsh/plugins/zsh-users/antigen"
	if [ ! -f "${ANTIGEN_LOCATION}/antigen.zsh" ]; then
		echo "Installing antigen"
		mkdir -p "${ANTIGEN_LOCATION}"
		curl -L git.io/antigen > "${ANTIGEN_LOCATION}/antigen.zsh"
	fi
}

# Load manually managed plugins
for f (${HOME}/.config/zsh/plugins/**/*.zsh) source "$f"

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Autosuggestions
antigen bundle zsh-users/zsh-autosuggestions

# Zsh completions
antigen bundle zsh-users/zsh-completions

# Zsh history fzf
antigen bundle joshskidmore/zsh-fzf-history-search

# Set powerlevel10k theme
antigen theme romkatv/powerlevel10k

# Apply all settings
antigen apply

# Load custom functions
export fpath=( ~/.config/zsh/plugins/**/functions ${fpath[@]} )
autoload ~/.config/zsh/plugins/**/functions/*(:t)

# has to be last line
tmux_autoload
