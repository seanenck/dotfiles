filetype plugin on
set confirm
set noautoindent
set background=dark
set nowrap
set whichwrap=b,s,<,>,[,]
set termwinkey=<C-t>
set termwinsize=15x0
let &g:directory=$HOME . '/.vim'
let aledir = expand(&g:directory . '/pack/dist/start/ale//')
let airlinedir = expand(&g:directory . '/pack/dist/start/vim-airline//')
let machinedir = expand($HOME . './machine/vimrc')
if isdirectory(aledir)
    let g:ale_completion_enabled = 1
endif

colo slate

function ToggleLine()
    if &colorcolumn == 81
        let &colorcolumn=0
    else
        highlight ColorColumn ctermbg=235 guibg=#592929
        let &colorcolumn=join(range(81,81),",")
    endif
endfunction

func NewTerminal()
    let bufs=filter(range(1, bufnr('$')), 'bufexists(v:val) && '.
                                      \'getbufvar(v:val, "&buftype") == "terminal"')
    if empty(bufs)
        :botright terminal
    else
        :call win_gotoid(get(win_findbuf(bufs[0]), 0))
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
if exists(machinedir)
    set backspace=2
    noremap <BS> <delete>
endif

set number
set tabstop=4
set expandtab
if has("autocmd")
    autocmd Filetype go setlocal noexpandtab
    autocmd BufNewFile,BufRead *.gxs setlocal ft=gxs syntax=gxs
    autocmd BufNewFile,BufRead *.md setlocal spell
endif

set shiftwidth=4
set foldmethod=indent
set foldlevelstart=99

for i in ['q', '<F1>']
    execute "map " . i . " <Nop>"
endfor
imap <F1> <Nop>

nnoremap <C-e> :call ToggleLine()<CR>

nnoremap <C-c> :close<CR>
nnoremap <C-v> :vsplit<CR>

let loaded_netrwPlugin = 1

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
nnoremap <C-t> :call NewTerminal()<CR>

if isdirectory(aledir)
    set omnifunc=syntaxcomplete#Complete
    set completeopt=noinsert
    let g:ale_set_highlights = 0
    let g:ale_sign_column_always = 1
    nmap <silent> <C-F> <Plug>(ale_find_references)
    nmap <silent> <C-G> <Plug>(ale_go_to_definition)
    nmap <silent> <C-H> <Plug>(ale_previous_wrap)
    nmap <silent> <C-J> <Plug>(ale_next_wrap)
    let g:ale_linters = {}
    let g:ale_linters.go = ['gopls', 'revive', 'goimports', 'govet']
    let g:ale_linters.python = ['pylsp', 'pycodestyle', 'flake8', 'pydocstyle']
endif

if isdirectory(airlinedir)    
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
    set hidden
    nmap <C-n> :enew<CR>
    nmap <Tab> :bnext<CR>
    nmap <S-Tab> :bprevious<CR>
    nmap <C-w> :bp <BAR> bd #<CR>
endif
