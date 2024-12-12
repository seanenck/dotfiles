augroup vimrcEx
au!

autocmd FileType markdown,text setlocal textwidth=78 spell
autocmd FileType loclist setlocal wrap linebreak

" set directory as readonly
autocmd BufEnter *
    \ if isdirectory(@%) |
    \   setlocal readonly |
    \ endif

" Return to where we last were
autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

autocmd FileType sh setlocal shiftwidth=2

autocmd CmdlineChanged *
    \ let cmd = getcmdline() |
    \ if !empty(cmd) |
    \   let wq = matchstr(cmd, "^wq.") |
    \   let partial = matchstr(cmd, "^'<,'>") |
    \   if !empty(wq) || !empty(partial) |
    \     call setcmdline('') |
    \   endif |
    \ endif

augroup END
