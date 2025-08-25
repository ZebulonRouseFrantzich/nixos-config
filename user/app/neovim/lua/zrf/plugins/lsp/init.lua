local plugin_utils = require("zrf.plugins.utils")

function lsp_on_attach(_, bufnr)
  -- we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

  if nixCats('general') then
    nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
    nmap('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
    nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
    nmap('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')
  end

  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

end

-- NOTE: Register a handler from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger vim.lsp.enable and the rtp config collection only on the correct filetypes
-- it adds the lsp field used below
-- (and must be registered before any load calls that use it!)
require("lze").register_handlers(require("lzextras").lsp)
-- also replace the fallback filetype list retrieval function with a slightly faster one
require("lze").h.lsp.set_ft_fallback(function(name)
	return dofile(nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) .. "/lsp/" .. name .. ".lua").filetypes
		or {}
end)

require('lze').load({
  {
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
      vim.lsp.config('*', {
        on_attach = lsp_on_attach -- require("zrf.plugins.lsp.config.keymaps").lsp_on_attach,
      })
    end,
  }
})

local lsps_to_load = {
  "lua_ls",
  "nixd",
  "typescript-tools-nvim",
  "ruby-lsp"
}
local loaded_lsps = plugin_utils.getTablesFromFiles(lsps_to_load, "zrf.plugins.lsp.")
require("lze").load(loaded_lsps)
