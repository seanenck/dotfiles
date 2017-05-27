if !has('python')
	finish
endif

let $VIMHOME = $HOME . "/.vim/plugin/"
let $PYCOMP = $VIMHOME . "completions.py"
let $PYSHIFT = $VIMHOME . "shift_buffer.py"
let $PYGITDIFF = $VIMHOME . "git_diff.py"
function! PyCompletion(direction)
	:pyfile $PYCOMP
endfunc

function! PyShift(direction)
    :pyfile $PYSHIFT
endfunc

function! PyGitDiff(buffer)
    :pyfile $PYGITDIFF
endfunc
