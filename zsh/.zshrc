# Load custom configuration from ~/.config/zsh

for FILE in ${HOME}/.config/zsh/functions/**/*.zsh; do
  if [ -f $FILE ]; then
    source $FILE
  fi
done

