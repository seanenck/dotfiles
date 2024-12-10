if executable('gopls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls']},
        \ 'allowlist': ['go', 'gomod'],
        \ 'initialization_options': {
        \     'gofumpt': v:true,
        \     'staticcheck': v:true,
        \  },
        \ })
    autocmd BufWritePre *.go
        \ call execute('LspDocumentFormatSync')
    autocmd BufEnter *.go
        \ setlocal omnifunc=lsp#complete
endif

highlight link LspInformationHighlight Todo

let g:lsp_use_native_client = 1
let g:lsp_diagnostics_virtual_text_align = "after"
let g:lsp_diagnostics_virtual_text_padding_left = 5
let g:lsp_document_code_action_signs_enabled = 0
let g:lsp_fold_enabled = 0
let g:lsp_diagnostics_highlights_delay = 50
let g:lsp_diagnostics_virtual_text_delay = 50
let g:lsp_diagnostics_signs_delay = 50
let g:lsp_diagnostics_float_cursor = 1

function! s:on_lsp_buffer_enabled() abort
    setlocal signcolumn=yes
    let g:lsp_format_sync_timeout = 1000
    nnoremap <buffer> <C-e> <cr>:LspDocumentDiagnostics<cr>
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
