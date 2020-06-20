" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
set noautoindent
set background=dark
set nowrap
highlight OverLength ctermbg=238 ctermfg=255 guibg=#592929
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
endif

set directory=$HOME/.vim/swap
if has('persistent_undo')
    set undodir=$HOME/.vim/undo
    set undofile
    set undolevels=5000
endif

set viminfo+=n$HOME/.vim/viminfo
vnoremap <S-Right> >gv
vnoremap <S-Left> <gv
inoremap <S-Left> <C-o>:<<CR>
inoremap <S-Right> <C-o>:><CR>

" map to command and insert
for i in ['', 'i']
    execute i . "noremap <C-Up> <PageUp>"
    execute i . "noremap <C-Down> <PageDown>"
    execute i . "noremap <C-Right> <end>"
    execute i . "noremap <C-Left> <home>"
endfor

set number
let extension = expand('%:e')
set tabstop=4
if extension == "go"
    set noexpandtab
else
    match OverLength /\%80v.\+/
    set tabstop=4
    set expandtab
endif

set shiftwidth=4
set foldmethod=indent
set foldlevelstart=99

for i in ['q', '<F1>']
    execute "map " . i . " <Nop>"
endfor
imap <F1> <Nop>

nnoremap <C-L> :vsplit<cr>
nnoremap <C-J> <C-W><C-L>
nnoremap <C-K> <C-W><C-H>
nnoremap <C-H> :close<cr>

nnoremap <C-o> :call fzf#run({'source': 'if [ -d .git ]; then git ls-files; else find . -type f; fi', 'sink': 'e', 'window': '30vnew'})<cr>

try
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#fnamemod = ':t'
    set hidden
    nmap <C-n> :enew<cr>
    nmap <C-t> :enew<cr>
    nmap <C-PageUp> :bprevious<cr>
    nmap <C-PageDown> :bnext<cr>
    nmap <C-w> :bp <BAR> bd #<cr>
catch
endtry
