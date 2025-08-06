return {
	"nixd",
	enabled = nixCats("nix") or false,
	lsp = {
		filetypes = { "nix" },
		settings = {
			nixd = {
				-- nixd requires some configuration.
				-- luckily, the nixCats plugin is here to pass whatever we need!
				-- we passed this in via the `extra` table in our packageDefinitions
				-- for additional configuration options, refer to:
				-- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
				nixpkgs = {
					-- in the extras set of your package definition:
					-- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
					expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
				},
				options = {
					nixos = {
						-- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
						expr = nixCats.extra("nixdExtras.nixos_options"),
					},
					["home-manager"] = {
						-- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
						expr = nixCats.extra("nixdExtras.home_manager_options"),
					},
				},
				formatting = {
					command = { "alejandra" },
				},
				diagnostic = {
					suppress = {
						"sema-escaping-with",
					},
				},
			},
		},
	}
}
