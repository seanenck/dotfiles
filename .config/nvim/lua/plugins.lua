-- airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

-- scrollbar
require("scrollbar").setup({})

-- enable LSPs
require("lsp")

vim.notify = require("notify").setup({
    background_colour = "#000000"
})
