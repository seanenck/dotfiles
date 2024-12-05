let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" ale specific
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1
let g:ale_lint_on_save = 1
let g:ale_completion_enabled = 1
let g:ale_detail_to_floating_preview = 1
let g:ale_linters = {}
let g:ale_linters.go = ['gopls']
let g:ale_linters.sh = ['shellcheck']
let g:ale_fixers = {}
let g:ale_fixers.go = ["gofumpt"]
let g:ale_go_gopls_init_options = {'ui.diagnostic.staticcheck': v:true}
let g:ale_hover_to_floating_preview = 1
highlight clear ALEError

" vim-lsp specific
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

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
