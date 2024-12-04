let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

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
