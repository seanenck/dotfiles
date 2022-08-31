set shell=/bin/bash

call plug#begin('~/.local/share/nvim/plugged')
    Plug 'dense-analysis/ale'
    Plug 'vim-airline/vim-airline'
    Plug 'akinsho/toggleterm.nvim', {'tag': 'v2.*'}
call plug#end()

lua << EOF
require("toggleterm").setup{}
EOF

" Options
set background=dark
set completeopt=noinsert
set confirm
set expandtab
set mouse=a
set noautoindent
set noerrorbells
set novisualbell
set nowrap
set number
set omnifunc=syntaxcomplete#Complete
set shiftwidth=4
set smartcase
set smartindent
set softtabstop=4
set tabstop=4
set termguicolors
set undofile
set undolevels=5000
set virtualedit=onemore
set whichwrap=b,s,<,>,[,],h,l

" Mouse without paste on middle click
for i in ['', '2-', '3-', '4-']
	execute "map <" . i . "MiddleMouse> <Nop>"
	execute "imap <" . i . "MiddleMouse> <Nop>"
endfor

" Disable help keys
map <F1> <Nop>
imap <F1> <Nop>

" Disable macro recording
map q <Nop>

" Disable EVERYTHING associated with up,down,left,right
noremap! <Up> <Nop>
noremap! <Down> <Nop>
noremap! <Left> <Nop>
noremap! <Right> <Nop>
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
noremap! <S-Up> <Nop>
noremap! <S-Down> <Nop>
noremap! <S-Left> <Nop>
noremap! <S-Right> <Nop>
noremap <S-Up> <Nop>
noremap <S-Down> <Nop>
noremap <S-Left> <Nop>
noremap <S-Right> <Nop>

" Buffer/airline/tab movements
nnoremap <C-l> :bn<CR>
nnoremap <C-h> :bp<CR>
nnoremap <C-w> :bp <BAR> bd #<CR>
nnoremap <C-k> :vsplit<CR>
nnoremap <C-j> :close<CR>
nnoremap <S-l> :wincmd l<CR>
nnoremap <S-h> :wincmd h<CR>

" ToggleTerm
nmap <C-t> :ToggleTerm direction=float<CR>
tmap <ESC> exit<CR>

" Ale Settings
let g:ale_set_highlights = 0
let g:ale_sign_column_always = 1
let g:ale_linters = {}
let g:ale_linters.go = ['gopls', 'revive', 'goimports', 'govet']
let g:ale_linters.python = ['pylsp', 'pycodestyle', 'flake8', 'pydocstyle']
let g:ale_completion_enabled = 1

" Airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" Open at last spot in line. from defaults.vim
augroup remember_position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" Spelling/line wrapping defaults
augroup text_files
    autocmd!
    autocmd BufRead,BufNewFile *.md,*.txt setlocal textwidth=80 spell
    autocmd BufNewFile,BufRead /tmp/mutt* set noautoindent filetype=mail wm=0 tw=80 nonumber nolist
    autocmd BufNewFile,BufRead /tmp/mutt* setlocal spell
augroup END
