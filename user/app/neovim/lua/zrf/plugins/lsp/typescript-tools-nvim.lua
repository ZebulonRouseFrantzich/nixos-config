return {
  "typescript-tools.nvim",
  enabled = nixCats("typescript") or false,
  lsp = {
    filetypes = { "typescript", "javascript" }
  },
  after = function(plugin)
    require("typescript-tools").setup({
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    })
  end,
}
