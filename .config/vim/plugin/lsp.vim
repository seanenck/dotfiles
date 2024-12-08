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
if executable("efm-langserver")
    au User lsp_setup call lsp#register_server({
        \ 'name': 'efm-langserver',
        \ 'cmd': {server_info->['efm-langserver']},
        \ 'allowlist': ['bash', 'sh'],
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(
		\	lsp#utils#find_nearest_parent_file_directory(
		\		lsp#utils#get_buffer_path(),
		\		['.git/']
		\	))},
		\ 'initialization_options': {},
        \ })
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

" handle completions
inoremap <C-Return> <C-x><C-o>
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

function! s:on_lsp_buffer_enabled() abort
    setlocal signcolumn=yes
    let g:lsp_format_sync_timeout = 1000
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:buffer_lsp_diagnostics_enabled = 1

function s:ToggleLSPDiagnostics()
    if g:buffer_lsp_diagnostics_enabled == 1
        call lsp#disable_diagnostics_for_buffer()
        let g:buffer_lsp_diagnostics_enabled = 0
    else
        call lsp#enable_diagnostics_for_buffer()
        let g:buffer_lsp_diagnostics_enabled = 1
    endif
endfunction

command ToggleLSPDiagnostics call s:ToggleLSPDiagnostics()

nnoremap <silent> <C-o> :ToggleLSPDiagnostics<CR>
