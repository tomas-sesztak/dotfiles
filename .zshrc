# Add homebrew to PATH
export PATH="/opt/homebrew/bin:${HOME}/.bin:${PATH}"

# Fix modern sed version
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Antigen plugin manager

source /opt/homebrew/share/antigen/antigen.zsh

# Oh-My-Zsh addon
antigen use oh-my-zsh

antigen bundle git
antigen bundle pip
antigen bundle web-search
antigen bundle vi-mode

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Autosuggestions
antigen bundle zsh-users/zsh-autosuggestions

# Zsh completions
antigen bundle zsh-users/zsh-completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Set powerlevel10k theme
antigen theme romkatv/powerlevel10k

# Apply all settings
antigen apply

# Set vi-mode
bindkey -v

# Fix reverse search in vi-mode
bindkey "^R" history-incremental-search-backward

# Aliases
alias ll="ls -la"

