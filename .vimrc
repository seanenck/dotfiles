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

function! Smart_TabComplete()
  let line = getline('.')
  " from the start to one character right of cursor
  let substr = strpart(line, -1, col('.'))
  " word to cursor
  let substr = matchstr(substr, "[^ \t|\.]*$")
  " empty string, nothing to match
  if (strlen(substr)==0)
    return "\<tab>"
  endif
  let has_period = match(substr, '\.') != -1
  let has_slash = match(substr, '\/') != -1
  if (!has_period && !has_slash)
    " text
    return "\<C-X>\<C-P>"
  elseif ( has_slash )
    " file
    return "\<C-X>\<C-F>"
  else
    " plugin
    return "\<C-X>\<C-O>"
  endif
endfunction

hi PMenu ctermfg=242 ctermbg=0
hi PMenuSel ctermbg=242
set wildmode=longest,list,full
set wildmenu
set completeopt=menuone
inoremap <expr> <TAB> Smart_TabComplete()

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
if extension == "go"
    set tabstop=4
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


" airline
" git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/dist/start/vim-airline
set hidden
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
nmap <C-n> :enew<cr>
nmap <C-PageUp> :bprevious<cr>
nmap <C-PageDown> :bnext<cr>
nmap <C-w> :bp <BAR> bd #<cr>
