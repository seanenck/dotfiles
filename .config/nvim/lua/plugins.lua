vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

require("lsp")

require("scrollbar").setup({})

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  callback = function()
    if vim.bo.filetype == "sh" then
        require("lint").try_lint("shellcheck")
    end
  end,
})
