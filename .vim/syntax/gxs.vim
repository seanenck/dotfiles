" Vim syntax file
" Filenames: *.gxs

if exists("b:current_syntax")
  finish
end

syn match gxsComment '\s*#.*$'
syn match gxsDirective '\v^(palette|action|mode|pattern|action)' skipwhite
syn match gxsOperator '=>'
syn match gxsStartBlock '{'
syn match gxsEndBlock '}'

hi link gxsComment Comment
hi link gxsDirective Identifier
hi link gxsOperator Statement
hi link gxsSTartBlock Function
hi link gxsEndBlock Function

let b:current_syntax = "gxs"
