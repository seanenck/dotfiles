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

augroup termIgnore
    autocmd!
    autocmd TerminalOpen * set nobuflisted
augroup END
