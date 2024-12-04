noremap <F1> <NOP> 
nnoremap q <NOP>

" disable shift movements
noremap <S-Up> <NOP>
noremap <S-Down> <NOP>
noremap <S-Right> <NOP>
noremap <S-Left> <NOP>
noremap <S-j> <NOP>
noremap <S-h> <NOP>
noremap <S-k> <NOP>
noremap <S-l> <NOP>
noremap <C-h> <NOP>
noremap <C-l> <NOP>
noremap <C-q> <NOP>
noremap <C-j> <NOP>
noremap <C-k> <NOP>

" mouse handling
noremap <Rightmouse> <NOP>
for i in ['', '2-', '3-', '4-']
    let mouse = "<" . i . "MiddleMouse>"
    noremap mouse <NOP>
endfor

" airline/tabs
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <C-w> :bprevious <BAR> bd #<CR>
nnoremap <S-l> :wincmd l<CR>
nnoremap <S-h> :wincmd h<CR>

" cursor movement
nnoremap gl $
nnoremap gh ^
nnoremap gk gg
nnoremap gj G
vnoremap gl $
vnoremap gh ^
vnoremap gk gg
vnoremap gj G

" location list
nnoremap <silent> <C-e> <Cmd>lopen<CR>
nnoremap <silent> <C-h> <Cmd>ALEHover<CR>
