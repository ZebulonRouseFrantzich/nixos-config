return {
	"gopls",
	enabled = nixCats("go") or false,
	-- if you don't provide the filetypes it asks lspconfig for them using the function we set above
	lsp = {
		-- filetypes = { "go", "gomod", "gowork", "gotmpl" },
	}
}
