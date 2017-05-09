if !has('python')
	finish
endif
 
function! PyCompletion()
	pyfile vim_completions.py
endfunc

function! PyCompletionReverse()
    python import sys
    python sys.argv = [1]
	pyfile vim_completions.py
endfunc
