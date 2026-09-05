if CheckDeps('fzf.vim', ['fzf', 'rg'])

function! FZF() abort
  let l:tempname = tempname()
  " fzf | awk '{ print $1":1:0" }' > file
  execute 'silent !fzf --multi ' . '| awk ''{ print $1":1:0" }'' > ' . fnameescape(l:tempname)
  try
    execute 'cfile ' . l:tempname
    redraw!
  finally
    call delete(l:tempname)
  endtry
endfunction

" :Files
command! -nargs=* Files call FZF()

" \ff
nnoremap <leader>ff :Files<cr>

function! RG(args) abort
  let l:tempname = tempname()
  " Default to current word under cursor if no args provided
  let l:pattern = empty(a:args) ? expand('<cword>') : a:args

  " Flags explained:
  " --line-number: Required for Vim to know where to jump
  " --no-heading: Puts the filename on every line (standard grep format)
  " --color=never: Prevents ANSI escape codes from breaking the Quickfix list
  " --smart-case: Case-insensitive search unless capital letters are used
  let l:cmd = printf('rg --line-number --no-heading --color=never --smart-case %s | fzf -m > %s',
      \ shellescape(l:pattern),
      \ fnameescape(l:tempname))

  execute 'silent !' . l:cmd
  redraw!
  try
    execute 'cfile ' . l:tempname
    redraw!
  finally
    call delete(l:tempname)
  endtry
endfunction

" :Rg [pattern]
command! -nargs=* Rg call RG(<q-args>)

" \fs
nnoremap <leader>fs :Rg<cr>

function! FZFBuffers() abort
  " Collect names of all listed buffers
  let l:bufs = map(getbufinfo({'buflisted':1}), 'v:val.name')
  let l:buflist = join(filter(l:bufs, '!empty(v:val)'), "\n")

  if empty(l:buflist)
    echo "No named buffers open."
    return
  endif

  let l:selection = system('printf ' . shellescape(l:buflist) . ' | fzf')

  if !empty(l:selection)
    let l:selection = substitute(l:selection, '\n$', '', '')
    execute 'buffer ' . fnameescape(l:selection)
  endif

  redraw!
endfunction

nnoremap <leader>fb :call FZFBuffers()<CR>

endif

