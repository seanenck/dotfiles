if !has('python3')
    :echo "python(3) installed?"
	finish
endif

let $VIMHOME = $HOME . "/.vim/plugin/"
let $PYSHIFT = $VIMHOME . "shift_buffer.py"

function! PyShift(direction)
    :py3file $PYSHIFT
endfunc
