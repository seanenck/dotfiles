if !has('python')
	finish
endif

let $PY_COMP = $HOME . "/.vim/plugin/vim_completions.py"
function! PyCompletion(direction)
	:pyfile $PY_COMP
endfunc
