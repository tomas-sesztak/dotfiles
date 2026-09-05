" Warn about missing external binaries required by a plugin.
" Returns 1 if all binaries are present, 0 otherwise.
function! CheckDeps(name, binaries) abort
  let l:missing = filter(copy(a:binaries), '!executable(v:val)')

  if !empty(l:missing)
    echohl WarningMsg
    echom printf('[%s] missing required binaries: %s', a:name, join(l:missing, ', '))
    echohl None
  endif

  return empty(l:missing)
endfunction
