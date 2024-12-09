let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

def RunShellCheck()
    g:informal_namespace = "shellcheck"
    if &ft ==# 'sh'
        exe ":ShellCheck"
        exe ":InformalUpdate"
    endif
enddef

autocmd BufWrite,BufEnter * call RunShellCheck()
