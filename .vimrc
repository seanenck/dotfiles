filetype plugin on
filetype plugin indent on
syntax on

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

highlight Pmenu ctermbg=grey guibg=grey ctermfg=black guifg=black
let loaded_netrwPlugin = 1
