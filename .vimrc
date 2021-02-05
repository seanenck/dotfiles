set noautoindent
set background=dark
set nowrap
set whichwrap=b,s,<,>,[,]

let g:ale_completion_enabled = 1

function ToggleLine()
    if &colorcolumn == 81
        let &colorcolumn=0
    else
        highlight ColorColumn ctermbg=235 guibg=#592929
        let &colorcolumn=join(range(81,81),",")
    endif
endfunction

call ToggleLine()
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

    " Return to where we last were
    autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

    augroup END
endif

let &g:directory=$HOME . '/.vim'
let &g:undodir=&g:directory . '/undo//'
let &g:backupdir=&g:directory . '/backup//'
let &g:directory=&g:directory . '/swap//'
if ! isdirectory(expand(&g:directory))
    silent! call mkdir(expand(&g:directory), 'p', 0700)
endif
if ! isdirectory(expand(&g:backupdir))
    silent! call mkdir(expand(&g:backupdir), 'p', 0700)
endif
if ! isdirectory(expand(&g:undodir))
    silent! call mkdir(expand(&g:undodir), 'p', 0700)
endif

if has('persistent_undo')
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
set tabstop=4
set expandtab
if has("autocmd")
    autocmd Filetype go setlocal noexpandtab
endif

set shiftwidth=4
set foldmethod=indent
set foldlevelstart=99

for i in ['q', '<F1>']
    execute "map " . i . " <Nop>"
endfor
imap <F1> <Nop>

nnoremap <C-e> :call ToggleLine()<CR>

nnoremap <C-L> <C-W><C-L>
nnoremap <C-K> <C-W><C-H>
nnoremap <C-c> :close<CR>
nnoremap <C-v> :vsplit<CR>

let loaded_netrwPlugin = 1

if filereadable("/etc/vim/vimrc.local")
    source /etc/vim/vimrc.local
endif

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

filetype plugin on
set omnifunc=syntaxcomplete#Complete
:set completeopt=longest,menuone
:inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

let g:ale_sign_column_always = 1
nmap <silent> <C-H> <Plug>(ale_previous_wrap)
nmap <silent> <C-J> <Plug>(ale_next_wrap)
let g:ale_linters = {}
if executable('gopls')
    let g:ale_linters.go = ['gopls', 'revive', 'goimports', 'govet']
endif
if executable('pyls')
    let g:ale_linters.python = ['pyls']
endif

try
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
    set hidden
    nmap <C-n> :enew<CR>
    nmap <C-t> :enew<CR>
    nmap <C-PageUp> :bprevious<CR>
    nmap <C-PageDown> :bnext<CR>
    nmap <C-w> :bp <BAR> bd #<CR>
catch
endtry

let NERDTreeShowHidden=1
nnoremap <C-o> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
