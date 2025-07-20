{
  description = "ZRF Flake";

  inputs = {
    # This pins your packages to a specific version of the nixpkgs repository.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # This is the main output that builds your NixOS system.
    # 'nixos' should match your system's hostname.
    nixosConfigurations.wilder-laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; # Pass inputs to your modules
      modules = [
        # This is where you import your existing configuration.
        ./configuration.nix
        hyprland.nixosModules.default
      ];
    };
    homeConfigurations = {
      zrf = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ ./home.nix ];
      };
    };
  };
}
