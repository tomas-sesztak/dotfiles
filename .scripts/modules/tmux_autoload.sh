function tmux_load_session() {
  source "$1"
  if [ ! "$SESSION_NAME" = "helloworld" ]; then
    tmux has-session -t "$SESSION_NAME" >/dev/null 2>&1
    if ! tmux has-session -t "$SESSION_NAME" >/dev/null 2>&1; then
      tmux new-session -s "$SESSION_NAME" -c "$SESSION_PATH" -n "${SESSION_WINDOW_NAME:-${SESSION_NAME}}" -d
      tmux send -t "$SESSION_NAME" "$SESSION_COMMAND" Enter
    fi
  fi
}


function tmux_autoload() {
  for file in ~/.config/tmux/tmux-sessions/*
  do
    tmux_load_session "$file"
  done
}

zle -N tmux_autoload
bindkey '^l' tmux_autoload

