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

for FILE in "${HOME}"/.config/zsh/functions/**/*.zsh; do
  [[ $FILE == */late/* ]] && continue
  if [ -f "$FILE" ]; then
    source "$FILE"
  fi
done

# Sourced last (e.g. zsh-syntax-highlighting must follow all widget definitions)
for FILE in "${HOME}"/.config/zsh/functions/late/*.zsh(N); do
  source "$FILE"
done
