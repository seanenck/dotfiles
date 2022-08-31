vim.fn['plug#begin'](vim.fn.stdpath('data') .. '/plugged') 
vim.fn['plug#']('dense-analysis/ale')
vim.fn['plug#']('akinsho/toggleterm.nvim', 'v2.*')
vim.fn['plug#']('vim-airline/vim-airline')
vim.fn['plug#end']()    

require("toggleterm").setup{}
