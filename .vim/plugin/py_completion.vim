if !has('python')
	finish
endif

let $PY_COMP = $HOME . "/.vim/plugin/completions.py"
function! PyCompletion(direction)
	:pyfile $PY_COMP
endfunc
