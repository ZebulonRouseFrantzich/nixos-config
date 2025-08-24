return {
	"lualine.nvim",
	enabled = nixCats("general") or false,
	-- cmd = { "" },
	event = "DeferredUIEnter",
	-- ft = "",
	-- keys = "",
	-- colorscheme = "",
	load = function(name)
		vim.cmd.packadd(name)
	end,
	after = function(plugin)
		require("lualine").setup({
			options = {
				icons_enabled = false,
				theme = "tokyonight",
				component_separators = "|",
				section_separators = "",
			},
			sections = {
				lualine_b = {
					{
						'lsp_status',
						icon = '', -- f013
						symbols = {
							-- Standard unicode symbols to cycle through for LSP progress:
							spinner = { '⣾', '⣷', '⣯', '⣟', '⡿', '⢿', '⣻', '⣽' },
							-- Standard unicode symbol for when LSP is done:
							done = '✓',
							-- Delimiter inserted between LSP names:
							separator = ' ',
						},
						-- List of LSP names to ignore (e.g., `null-ls`):
						ignore_lsp = {},
					}
				},
				lualine_c = {
					{
						"filename",
						path = 1,
						status = true,
					},
				},
			},
			inactive_sections = {
				lualine_b = {
					{
						"filename",
						path = 3,
						status = true,
					},
				},
				lualine_x = { "filetype" },
			},
			tabline = {
				lualine_a = { "buffers" },
				lualine_b = { "lsp_status" },
				lualine_z = { "tabs" },
			},
		})
	end
}
