local plugin_utils = require("zrf.plugins.utils")

local plugins_to_load = {
  "which-key",
  "blink-cmp",
  "nvim-treesitter",
  "mini-nvim",
  "vim-startuptime",
  "lualine-nvim",
  "gitsigns-nvim",
  "nvim-lint",
  "conform-nvim",
  "nvim-dap",
  "nvim-dap-go",
  "lazydev-nvim",
  "grapple-nvim",
  "render-markdown-nvim",
}
local loaded_plugins = plugin_utils.getTablesFromFiles(plugins_to_load, "zrf.plugins.")
require("lze").load(loaded_plugins)
