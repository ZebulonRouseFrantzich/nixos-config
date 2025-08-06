local lsp_keymaps = require("zrf.plugins.lsp.config.keymaps")

return {
	"nvim-lspconfig",
	enabled = nixCats("general") or false,
	-- the on require handler will be needed here if you want to use the
	-- fallback method of getting filetypes if you don't provide any
	on_require = { "lspconfig" },
	-- define a function to run over all type(plugin.lsp) == table
	-- when their filetype trigger loads them
	lsp = function(plugin)
		vim.lsp.config(plugin.name, plugin.lsp or {})
		vim.lsp.enable(plugin.name)
	end,
	before = function(_)
		vim.lsp.config("*", {
			on_attach = lsp_keymaps.lsp_on_attach,
		})
	end
}
