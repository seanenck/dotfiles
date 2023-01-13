vim.o.runtimepath = vim.o.runtimepath .. ',/usr/share/vim/vimfiles'
vim.o.directory = "/home/enck/.cache/nvim"

-- Plugins
require("options")
require("helpers")
require("plugins")
require("autocmds")

-- Mouse, disable paste on middle click
for _, mouseMiddle in ipairs({"", "2-", "3-", "4-"}) do
    mapall("<" .. mouseMiddle .. "MiddleMouse>", '<Nop>')
end

-- Disable help
mapall("<F1>", "<Nop>")
-- Disable macros
nmap("q", "<Nop>")

-- Disable cursor keys
for _, cursor in ipairs({"<S-Up>", "<S-Down>", "<S-Right>", "<S-Left>"}) do
    mapall(cursor, "<Nop>")
end

-- Buffer/split movements
nmap("<Tab>", ":bnext<CR>")
nmap("<S-Tab>", ":bprevious<CR>")
nmap("<C-w>", ":bprevious <BAR> bd #<CR>")
nmap("<C-l>", ":vsplit<CR>")
nmap("<C-q>", ":close<CR>")
nmap("<S-l>", ":wincmd l<CR>")
nmap("<S-h>", ":wincmd h<CR>")

for _, write in ipairs({"w", "wq"}) do
    vim.api.nvim_exec(string.format("cabbrev <expr> %s getcmdtype()==':' && getcmdline() == \"'<,'>%s\" ? '<c-u>%s' : '%s'", write, write, write, write), false)
end
for _, name in ipairs({"1", "1q", "1Q"}) do
    local write = "w" .. name
    vim.api.nvim_exec(string.format("cabbrev %s <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'w!' : '%s')<CR>", write, write), false)
end

-- Remap completion to right arrow
vim.api.nvim_exec("inoremap <expr><silent> <Right> pumvisible() ? '<C-Y>' : '<Right>'", false)
