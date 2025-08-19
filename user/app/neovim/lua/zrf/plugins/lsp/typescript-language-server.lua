return {
  "ts_ls",
  enabled = nixCats("lsp"),
  lsp = {
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },
}
