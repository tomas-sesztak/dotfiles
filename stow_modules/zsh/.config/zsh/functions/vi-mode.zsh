# zle needs a real terminal; skip when sourced without one (e.g. `zsh -ic '...'` via a pipe)
[[ -t 1 ]] || return

# enable vi-mode
bindkey -v

function _cursor_mode() {
  #local cursor_block cursor_beam

  # Cursor styles
  # Set cursor style (DECSCUSR), VT520.
  # 0 -> blinking block.
  # 1 -> blinking block (default).
  # 2 -> steady block.
  # 3 -> blinking underline.
  # 4 -> steady underline.
  # 5 -> blinking bar, xterm.
  # 6 -> steady bar, xterm.
  cursor_block='\e[2 q'
  cursor_beam='\e[6 q'

  function zle-keymap-select() {
    if [[ ${KEYMAP} == vicmd ]] ||
        [[ $1 = 'block' ]]; then
      echo -ne $cursor_block
    elif [[ ${KEYMAP} == main ]] ||
          [[ ${keymap} == viins ]] ||
          [[ ${KEYMAP} == '' ]] ||
          [[ $1 = 'beam' ]]; then
      echo -ne $cursor_beam
    fi
  }

  zle-line-init() {
    echo -ne $cursor_beam
  }

  zle -N zle-keymap-select
  zle -N zle-line-init
}

_cursor_mode

# Press v in normal mode to edit command with $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Use jk to enter normal mode
bindkey -M viins 'jk' vi-cmd-mode

