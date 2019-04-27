" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim

set noautoindent
set background=dark
set nowrap
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if has("autocmd")
  filetype plugin indent on

  augroup vimrcEx
  au!

  autocmd FileType text setlocal textwidth=78

  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END
endif " has("autocmd")

set directory=$HOME/.vim/swap
if has('persistent_undo')
    set undodir=$HOME/.vim/undo
    set undofile
    set undolevels=5000
endif

set viminfo+=n$HOME/.cache/viminfo

" map to command and insert
for i in ['', 'i']
    execute i . "noremap <C-Up> <PageUp>"
    execute i . "noremap <C-Down> <PageDown>"
    execute i . "noremap <C-Right> <end>"
    execute i . "noremap <C-Left> <home>"
endfor

match OverLength /\%80v.\+/
set tabstop=4
set expandtab
set shiftwidth=4
set complete-=i
set foldmethod=indent
set foldlevelstart=99

for i in ['q', '<F1>']
    execute "map " . i . " <Nop>"
endfor
imap <F1> <Nop>
