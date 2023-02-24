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

-- Disable shifted cursor keys
for _, cursor in ipairs({"<S-Up>", "<S-Down>", "<S-Right>", "<S-Left>"}) do
    mapall(cursor, "<Nop>")
end

mapall("<C-k>", "")
mapall("<C-j>", "")
mapall("<C-h>", "")
mapall("<C-l>", "")
nmap("<C-l>", ":vsplit<CR>")
mapall("<C-q>", "")

-- Buffer/split movements
nmap("<Tab>", ":bnext<CR>")
nmap("<S-Tab>", ":bprevious<CR>")
nmap("<C-w>", ":bprevious <BAR> bd #<CR>")
nmap("<S-l>", ":wincmd l<CR>")
nmap("<S-h>", ":wincmd h<CR>")
local move_maps = { ["gl"] = "$", ["gh"] = "^", ["gk"] = "gg", ["gj"] = "G"}
for key, command in pairs(move_maps) do
    nmap(key, command)
    vmap(key, command)
end

-- Everything below is currently 'cheating' and using nvim_exec instead of the nvim api...
for _, write in ipairs({"w", "wq"}) do
    vim.api.nvim_exec(string.format("cabbrev <expr> %s getcmdtype()==':' && getcmdline() == \"'<,'>%s\" ? '<c-u>%s' : '%s'", write, write, write, write), false)
end
for _, name in ipairs({"1", "1q", "1Q"}) do
    local write = "w" .. name
    vim.api.nvim_exec(string.format("cabbrev %s <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'w!' : '%s')<CR>", write, write), false)
end

vim.api.nvim_set_hl(0, "Pmenu", {bg='black'})
vim.api.nvim_set_hl(0, "Search", {bg='peru', fg='wheat'})
