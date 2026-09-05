function! TmuxMove(direction) abort
  let l:old_win = winnr()

  execute 'wincmd ' . a:direction

  if l:old_win == winnr()
    let l:tmux_dir = {'h': 'L', 'j': 'D', 'k': 'U', 'l': 'R'}
    silent call system('tmux select-pane -' . l:tmux_dir[a:direction])
  endif
endfunction
