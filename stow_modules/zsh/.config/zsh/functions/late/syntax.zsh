if [[ "$OSTYPE" == darwin* ]]; then
  SYNTAX_HIGHLIGHTING_PATH="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
  SYNTAX_HIGHLIGHTING_PATH="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if [ -f "$SYNTAX_HIGHLIGHTING_PATH" ]; then
  source "$SYNTAX_HIGHLIGHTING_PATH"
fi
