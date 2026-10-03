# Tag the tmux window with its git repo as window option @repo; status bar shows only windows matching @active_repo
if [[ -n $TMUX ]]; then
  autoload -Uz add-zsh-hook

  function _tmux_repo_update() {
    local key="$(_git-repo-key)"
    [[ -n $_tmux_repo_set && $key == $_tmux_repo ]] && return
    _tmux_repo=$key _tmux_repo_set=1
    if [[ -n $key ]]; then
      command tmux set-option -wq -t "$TMUX_PANE" @repo "$key" \; if-shell -t "$TMUX_PANE" -F '#{window_active}' 'set-option -Fq @active_repo "#{@repo}"'
    else
      command tmux set-option -wuq -t "$TMUX_PANE" @repo \; if-shell -t "$TMUX_PANE" -F '#{window_active}' 'set-option -uq @active_repo'
    fi
  }

  add-zsh-hook chpwd _tmux_repo_update
  _tmux_repo_update
fi
