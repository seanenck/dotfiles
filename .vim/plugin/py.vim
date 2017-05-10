if !has('python')
	finish
endif

let $VIMHOME = $HOME . "/.vim/plugin/"
let $PYCOMP = $VIMHOME . "completions.py"
let $PYSHIFT = $VIMHOME . "shift_buffer.py"
function! PyCompletion(direction)
	:pyfile $PYCOMP
endfunc

function! PyShift(direction)
    :pyfile $PYSHIFT
endfunc
