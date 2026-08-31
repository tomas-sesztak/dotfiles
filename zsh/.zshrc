# macOS: add Homebrew paths (Apple Silicon and Intel)
if [[ "$OSTYPE" == darwin* ]]; then
  for BREW_PATH in /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin /usr/local/sbin; do
    if [ -d "$BREW_PATH" ]; then
      PATH="${BREW_PATH}:${PATH}"
    fi
  done
  export PATH
fi

# User-local binaries
if [ -d "${HOME}/.local/bin" ]; then
  PATH="${HOME}/.local/bin:${PATH}"
  export PATH
fi

# Load custom configuration from ~/.config/zsh

for FILE in ${HOME}/.config/zsh/functions/**/*.zsh; do
  if [ -f $FILE ]; then
    source $FILE
  fi
done
