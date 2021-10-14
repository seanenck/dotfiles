filetype plugin on
set confirm
set noautoindent
set background=dark
set nowrap
set whichwrap=b,s,<,>,[,]
let machinedir = expand($HOME . '/.machine/vimrc')
if filereadable(machinedir)
    exec 'source' machinedir
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

set number
set tabstop=4
set expandtab
set shiftwidth=4
set foldmethod=indent
set foldlevelstart=99

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

vnoremap <C-i> >gv
vnoremap <C-u> <gv

for i in ['q', '<F1>']
    execute "map " . i . " <Nop>"
endfor
imap <F1> <Nop>

nnoremap <C-e> :call ToggleLine()<CR>
nnoremap <C-v> :vsplit<CR>

let loaded_netrwPlugin = 1

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
