# Smartcase
setopt NO_CASE_GLOB

# Tmux directory for TPM
export TMUX_TPM_DIRECTORY="${HOME}/.config/tmux/plugins/tpm"

# Load custom functions
export fpath=( ~/.config/zsh/plugins/**/functions ${fpath[@]} )
autoload ~/.config/zsh/plugins/**/functions/*(:t)

