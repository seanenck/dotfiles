let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" setup informal shellcheck handling
def RunShellCheck()
    g:informal_namespace = "shellcheck"
    if &ft ==# 'sh'
        exe ":ShellCheck"
        exe ":InformalUpdate"
    endif
enddef

autocmd BufWrite,BufEnter * call RunShellCheck()

" handle completions
inoremap <C-Return> <C-x><C-o>
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" toggle on/off diagnostics
let g:buffer_diagnostics_enabled = 1
function s:ToggleDiagnostics()
    if g:buffer_diagnostics_enabled == 1
        call lsp#disable_diagnostics_for_buffer()
        let g:buffer_diagnostics_enabled = 0
        let g:informal_enable = v:false
    else
        let g:informal_enable = v:true
        call lsp#enable_diagnostics_for_buffer()
        let g:buffer_diagnostics_enabled = 1
    endif
    exe ":InformalUpdate"
endfunction

command ToggleDiagnostics call s:ToggleDiagnostics()

nnoremap <silent> <C-o> :ToggleDiagnostics<CR>
