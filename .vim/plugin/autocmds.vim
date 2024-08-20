augroup vimrcEx
au!

autocmd FileType markdown,text setlocal textwidth=78 spell
autocmd FileType loclist setlocal wrap linebreak
autocmd FileType qf nmap <buffer> <esc> <cr>:lcl<cr>
autocmd FileType loclist nmap <buffer> <esc> <cr>:lcl<cr>
autocmd FileType qf nmap <buffer> <cr> <cr>:lcl<cr>
autocmd FileType loclist nmap <buffer> <cr> <cr>:lcl<cr>

" Return to where we last were
autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

autocmd FileType sh setlocal shiftwidth=2

autocmd CmdlineChanged *
    \ let cmd = getcmdline() |
    \ if !empty(cmd) |
    \   let match = matchstr(cmd, "^wq.") |
    \   if !empty(match) |
    \     call setcmdline('') |
    \   endif |
    \ endif

augroup END
