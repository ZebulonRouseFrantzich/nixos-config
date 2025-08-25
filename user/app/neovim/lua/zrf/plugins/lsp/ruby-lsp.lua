return {
  "ruby_lsp",
  enabled = nixCats("ruby") or false,
  lsp = {
    filetypes = { "ruby" },
    init_options = {
      formatter = 'standard',
      linters = { 'standard' },
    }
  }
}
