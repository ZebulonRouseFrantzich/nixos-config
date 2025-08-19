return {
	"typescript-tools",
	enabled = nixCats("typescript") or false,
	lsp = {
		filetypes = { "typescript", "javascript" },
	}
}
