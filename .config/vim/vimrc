filetype plugin on
filetype plugin indent on
syntax on

set viminfo+=n$HOME/.cache/vim/viminfo
let &g:directory=$HOME . '/.cache/vim'
let &g:undodir=&g:directory . '/undo//'
let &g:backupdir=&g:directory . '/backup//'
let &g:directory=&g:directory . '/swap//'
function SetupVimDir(path, threshold)
    if ! isdirectory(expand(a:path))
        call mkdir(expand(a:path), 'p', 0700)
    endif
    call system("find " . a:path . " -type f " . a:threshold . " -delete")
endfunction
call SetupVimDir(&g:directory, "-mtime +1")
call SetupVimDir(&g:undodir, "-mmin +60")
call SetupVimDir(&g:backupdir, "-mtime +1")

highlight Pmenu ctermbg=grey guibg=grey ctermfg=black guifg=black
let loaded_netrwPlugin = 1
