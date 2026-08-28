""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set termguicolors

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set autoread when a file is changed from the outside
set autoread
au FocusGained,BufEnter * silent! checktime

" Map leader to ,
let mapleader = " "

" Turn on WildMenu
set wildmenu
set wildignore=*/.git/*,*/.DS_Store

" Always show current position
set ruler

" Command bar height
set cmdheight=1

" Configure backspace
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" Be smart about case when searching
set smartcase

" Highlight search results
set hlsearch

" Search like in modern browsers
set incsearch

" Don't redraw while executing macros
set lazyredraw

" Turn on magic for regexp
set magic

" Show matching brackets
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and fonts
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1

colorscheme tokyonight

syntax enable

" Automatically set regexp engine
set regexpengine=0

set background=dark

set encoding=utf8
set ffs=unix,dos,mac

" Disable swap file
set noswapfile

" Dont use tabs
set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set softtabstop=2

set autoindent
set smartindent
set wrap

set number
set relativenumber
set cursorline
set signcolumn=auto

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source ${HOME}/.vim/config/fzf.vim
source ${HOME}/.vim/config/tmux.vim

" Disable highlight
map <silent> <leader>, :nohl<cr>

" Splits
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>

set list
set listchars=tab:\ \ ,trail:<

" exit insert mode with jk
inoremap jk <esc>

" Reload configuration
map <leader>r :source ~/.vimrc<cr>

" Bind your Ctrl keys to the new function
nnoremap <silent> <C-h> :call TmuxMove('h')<CR>
nnoremap <silent> <C-j> :call TmuxMove('j')<CR>
nnoremap <silent> <C-k> :call TmuxMove('k')<CR>
nnoremap <silent> <C-l> :call TmuxMove('l')<CR>
