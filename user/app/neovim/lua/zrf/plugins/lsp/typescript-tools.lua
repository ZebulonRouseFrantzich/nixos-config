return {
  "typescript-tools",
  enabled = nixCats("typescript") or false,
  lsp = {
    filetypes = { "typescript", "javascript" },
  }
}

-- return {
--   "ts_ls",
--   enabled = nixCats("lsp"),
--   lsp = {
--     filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
--   },
-- }
