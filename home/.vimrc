filetype plugin on
set confirm
set noautoindent
set background=dark
set nowrap
set whichwrap=b,s,<,>,[,],h,l

if has("autocmd")
    autocmd BufNewFile,BufRead *.md setlocal spell
    autocmd BufNewFile,BufRead *.txt setlocal spell
    autocmd BufNewFile,BufRead /tmp/mutt* set noautoindent filetype=mail wm=0 tw=78 nonumber nolist
    autocmd BufNewFile,BufRead /tmp/mutt* setlocal spell
endif

set termwinkey=<C-t>
set termwinsize=20x0
func NewTerminal()
    let bufs=filter(range(1, bufnr('$')), 'bufexists(v:val) && '.
                                      \'getbufvar(v:val, "&buftype") == "terminal"')
    if empty(bufs)
        :botright terminal
    else
        :call win_gotoid(get(win_findbuf(bufs[0]), 0))
    endif
endfunction
nnoremap <C-t> :call NewTerminal()<CR>
tnoremap <ESC> <C-w>exit<CR>
let g:ale_completion_enabled = 1
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

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
set hidden

augroup termIgnore
    autocmd!
    autocmd TerminalOpen * set nobuflisted
augroup END

nmap <C-n> :enew<CR>
nmap <Tab> :bn<CR>
nmap <S-Tab> :bp<CR>
nmap <C-w> :bp <BAR> bd #<CR>

if has("mouse_sgr")
    set ttymouse=sgr
endif

function ToggleLine()
    if &colorcolumn == 81
        let &colorcolumn=0
    else
        highlight ColorColumn ctermbg=235 guibg=#592929
        let &colorcolumn=join(range(81,81),",")
    endif
endfunction

if has('mouse')
    set mouse=a
    for i in ['', '2-', '3-', '4-']
        execute "map <" . i . "MiddleMouse> <Nop>"
        execute "imap <" . i . "MiddleMouse> <Nop>"
    endfor
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

set number
set tabstop=4
set expandtab
set shiftwidth=4
set foldmethod=indent
set foldlevelstart=99
set virtualedit=onemore

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
    autocmd Filetype go setlocal noexpandtab
endif

set viminfo+=n$HOME/.vim/viminfo
let &g:directory=$HOME . '/.vim'
let &g:undodir=&g:directory . '/undo//'
let &g:backupdir=&g:directory . '/backup//'
let &g:directory=&g:directory . '/swap//'
function SetupVimDir(path)
    if ! isdirectory(expand(a:path))
        call mkdir(expand(a:path), 'p', 0700)
    endif
endfunction
call SetupVimDir(&g:directory)
call SetupVimDir(&g:undodir)
call SetupVimDir(&g:backupdir)

if has('persistent_undo')
    set undofile
    set undolevels=5000
endif

for i in ['q', '<F1>']
    execute "map " . i . " <Nop>"
endfor
imap <F1> <Nop>

nnoremap <C-e> :call ToggleLine()<CR>
nnoremap <C-u> :vsplit<CR>
nnoremap <S-l> :wincmd l<CR>
nnoremap <S-h> :wincmd h<CR>

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

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
