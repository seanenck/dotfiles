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

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
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
let pymode = $HOME . "/.vim/plugin/py.vim"
if findfile(pymode, ".") == pymode
    let g:pymode_python = 'python3'
    inoremap <S-Left> <C-o>:call PyShift(0)<CR>
    inoremap <S-Right> <C-o>:call PyShift(1)<CR>
endif

" map to command and insert
for i in ['', 'i']
    execute i . "noremap <C-Up> <PageUp>"
    execute i . "noremap <C-Down> <PageDown>"
    execute i . "noremap <C-Right> <end>"
    execute i . "noremap <C-Left> <home>"
endfor

let tmode = $HOME . "/.tmp/textmode"
if findfile(tmode, ".") == tmode
    set formatoptions+=w
    set formatoptions+=a
    set formatoptions+=n
    setlocal spell spelllang=en_us
    set wrap nolist linebreak
    set textwidth=80
    set list
    call delete(expand(tmode))
else
    set number
    match OverLength /\%80v.\+/
    set tabstop=4
    set expandtab
    set shiftwidth=4
    set complete-=i
    set foldmethod=indent
    set foldlevelstart=99
endif
