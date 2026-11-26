# Minimal syntax highlighting; sourced last so it sees every widget
[[ -t 1 ]] || return

autoload -Uz add-zle-hook-widget

function _synhl_update() {
  region_highlight=( ${region_highlight:#*memo=synhl*} )
  local tok style prefix start pos=0 cmdpos=1
  for tok in ${(Z+c+)BUFFER}; do
    prefix=${BUFFER:$pos}
    prefix=${prefix%%${(b)tok}*}
    start=$(( pos + $#prefix ))
    pos=$(( start + $#tok ))
    style=
    case $tok in
      ('|'|'||'|'&&'|';'|'&'|'|&'|'('|'{'|$'\n') style=fg=blue; cmdpos=1 ;;
      ('#'*) style=fg=8 ;;
      (*)
        if (( cmdpos )); then
          case $tok in
            ([[:alpha:]_]*=*) ;;
            (sudo|command|builtin|exec|noglob|time|nocorrect) style=fg=green ;;
            (*)
              cmdpos=0
              if whence -- ${(Q)tok} >/dev/null; then style=fg=green; else style=fg=red,bold; fi
              ;;
          esac
        elif [[ $tok == (\'*|\"*|\$\'*) ]]; then
          style=fg=yellow
        fi
        ;;
    esac
    [[ -z $style ]] || region_highlight+=( "$start $pos $style,memo=synhl" )
  done
}

add-zle-hook-widget line-pre-redraw _synhl_update
