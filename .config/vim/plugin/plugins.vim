let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

let g:qfdiagnostics = {"virttext": v:true}

def RunShellCheck()
    if &ft ==# 'sh'
        exe ":ShellCheck"
        exe ":DiagnosticsClear"
        exe ":DiagnosticsPlace"
    endif
enddef

autocmd BufWrite,BufEnter * call RunShellCheck()

" handle completions
inoremap <C-Return> <C-x><C-o>
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" toggle on/off diagnostics
let g:buffer_diagnostics_enabled = 1
function s:ToggleDiagnostics()
    if g:buffer_diagnostics_enabled == 1
        let g:buffer_diagnostics_enabled = 0
        exe ":DiagnosticsClear"
    else
        let g:buffer_diagnostics_enabled = 1
        exe ":DiagnosticsPlace"
    endif
endfunction

command ToggleDiagnostics call s:ToggleDiagnostics()

nnoremap <silent> <C-o> :ToggleDiagnostics<CR>

let g:go_gopls_staticcheck = v:true
let g:go_gopls_gofumpt = v:true
let g:go_diagnostics_level = 100
let g:go_doc_ballon = 1
let g:go_doc_popup_window = 1

autocmd filetype go nnoremap <buffer> <C-h> :GoDoc<CR>
autocmd FileType go nnoremap <buffer> <C-e> :GoDiagnostics<cr>
