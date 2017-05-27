" ===== START VIMRC system-wide config =====
" All system-wide defaults are set in $VIMRUNTIME/archlinux.vim (usually just
" /usr/share/vim/vimfiles/archlinux.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vimrc), since archlinux.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing archlinux.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim

" If you prefer the old-style vim functionalty, add 'runtime! vimrc_example.vim'
" Or better yet, read /usr/share/vim/vim74/vimrc_example.vim or the vim manual
" and configure vim to your own liking!
" ===== END VIMRC system-wide config =====

set noautoindent
set background=dark
set nowrap
set number
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%80v.\+/
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END
  autocmd FileType python inoremap <S-Up> <C-o>:call PyCompletion(0)<CR>
  autocmd FileType python inoremap <S-Down> <C-o>:call PyCompletion(1)<CR>
endif " has("autocmd")

inoremap <S-Left> <C-o>:call PyShift(0)<CR>
inoremap <S-Right> <C-o>:call PyShift(1)<CR>

for i in ['', 'i']
    execute i . "noremap <C-Up> <PageUp>"
    execute i . "noremap <C-Down> <PageDown>"
    execute i . "noremap <C-Right> <end>"
    execute i . "noremap <C-Left> <home>"
    execute i . "noremap <F1> :Texplore<CR>"
    execute i . "noremap <F2> :q<CR>"
    execute i . "noremap <F3> :ls<CR>"
    execute i . "noremap <F4> <C-o>:call PyGitDiff(0)<CR>"
    execute i . "noremap <F5> <C-o>:call PyGitDiff(1)<CR>"
endfor


set tabstop=4
set expandtab
set shiftwidth=4
set complete-=i
set foldmethod=indent
set foldlevelstart=99
