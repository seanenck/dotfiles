if !has('python')
	finish
endif

let $VIMHOME = $HOME . "/.vim/plugin/"
let $PYSHIFT = $VIMHOME . "shift_buffer.py"

function! PyShift(direction)
    :pyfile $PYSHIFT
endfunc
