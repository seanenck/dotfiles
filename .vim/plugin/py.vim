if !has('python')
	finish
endif

let $VIMHOME = $HOME . "/.vim/plugin/"
let $PYCOMP = $VIMHOME . "completions.py"
function! PyCompletion(direction)
	:pyfile $PYCOMP
endfunc
