-- airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

-- scrollbar
require("scrollbar").setup({})

-- enable LSPs if requested only
if os.getenv("ENABLE_LSP") ~= nil then
    require("lsp")
end
