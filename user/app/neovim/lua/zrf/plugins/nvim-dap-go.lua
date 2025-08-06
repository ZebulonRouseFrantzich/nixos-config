return {
	"nvim-dap-go",
	enabled = nixCats("go") or false,
	on_plugin = { "nvim-dap" },
	after = function(plugin)
		require("dap-go").setup()
	end
}
