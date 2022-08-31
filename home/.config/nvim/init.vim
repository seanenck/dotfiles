lua require("base")

" NOTE: somethings are easier in vimscript (for now at least)

" Ale Settings
let g:ale_set_highlights = 0
let g:ale_sign_column_always = 1
let g:ale_linters = {}
let g:ale_linters.go = ['gopls', 'revive', 'goimports', 'govet']
let g:ale_linters.python = ['pylsp', 'pycodestyle', 'flake8', 'pydocstyle']
let g:ale_completion_enabled = 1

" Airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
