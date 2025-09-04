vim.opt.mouse = 'a'
vim.opt.title = true
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.wrap = false
vim.opt.signcolumn = "yes"
vim.g.mapleader = " "

local signs = {
	Error = " ", -- nf-fa-times-circle
	Warn  = " ", -- nf-fa-exclamation-triangle
	Hint  = " ", -- nf-fa-lightbulb
	Info  = " ", -- nf-fa-info-circle
}

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

require("config.lazy")
require("config.lsp").setup()
