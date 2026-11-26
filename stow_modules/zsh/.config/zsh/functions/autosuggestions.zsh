# Fish-like history suggestions shown as grey ghost text
[[ -t 1 ]] || return 0

autoload -Uz add-zle-hook-widget

function _autosuggest_update() {
  POSTDISPLAY=
  region_highlight=( ${region_highlight:#*memo=autosuggest*} )
  [[ -n $BUFFER && $CURSOR -eq $#BUFFER ]] || return 0
  local suggestion=${history[(r)${(b)BUFFER}?*]}
  [[ -n $suggestion ]] || return 0
  POSTDISPLAY=${suggestion#$BUFFER}
  region_highlight+=( "$#BUFFER $(( $#BUFFER + $#POSTDISPLAY )) fg=8,memo=autosuggest" )
}

function _autosuggest_clear() {
  POSTDISPLAY=
}

function _autosuggest_accept() {
  if [[ -n $POSTDISPLAY ]]; then
    BUFFER+=$POSTDISPLAY
    POSTDISPLAY=
    CURSOR=$#BUFFER
  elif [[ $WIDGET == *end ]]; then
    zle .end-of-line
  else
    zle .forward-char
  fi
}

zle -N _autosuggest_accept
zle -N _autosuggest_accept_end _autosuggest_accept
add-zle-hook-widget line-pre-redraw _autosuggest_update
add-zle-hook-widget line-finish _autosuggest_clear

for keymap in viins emacs; do
  bindkey -M $keymap '^[[C' _autosuggest_accept '^[OC' _autosuggest_accept
  bindkey -M $keymap '^[[F' _autosuggest_accept_end '^[OF' _autosuggest_accept_end '^E' _autosuggest_accept_end
done
unset keymap
