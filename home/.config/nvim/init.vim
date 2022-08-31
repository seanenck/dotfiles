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

" Open at last spot in line. from defaults.vim
augroup remember_position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" Spelling/line wrapping defaults
augroup text_files
    autocmd!
    autocmd BufRead,BufNewFile *.md,*.txt setlocal textwidth=80 spell
    autocmd BufNewFile,BufRead /tmp/mutt* set noautoindent filetype=mail wm=0 tw=80 nonumber nolist
    autocmd BufNewFile,BufRead /tmp/mutt* setlocal spell
augroup END
