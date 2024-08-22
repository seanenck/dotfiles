-- airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

-- scrollbar
require("scrollbar").setup({})

-- enable LSPs
require("lsp")
