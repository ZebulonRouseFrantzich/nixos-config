local plugin_utils = require("zrf.plugins.utils")

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
        on_attach = require("zrf.plugins.lsp.config.keymaps").lsp_on_attach,
      })
    end,
  }
})

local lsps_to_load = {
	"lua_ls",
	"nixd",
	"typescript-language-server"
}
local loaded_lsps = plugin_utils.getTablesFromFiles(lsps_to_load, "zrf.plugins.lsp.")
require("lze").load(loaded_lsps)
