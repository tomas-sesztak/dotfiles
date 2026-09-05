if [[ "$OSTYPE" == darwin* ]]; then
  AUTOSUGGESTIONS_PATH="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
  AUTOSUGGESTIONS_PATH="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "$AUTOSUGGESTIONS_PATH" ]; then
  source "$AUTOSUGGESTIONS_PATH"
fi
