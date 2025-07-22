{
  description = "ZRF Core Flake";

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
    # Determine the current profile. Default to "personal".
    profileInfo = (
      if builtins.pathExists ./host.toml
      then builtins.fromTOML (builtins.readFile ./host.toml)
      else { profile = "personal"; }
    );

    # Load the settings files
    globalSettings = builtins.fromTOML (builtins.readFile ./settings/global.toml);
    profileSettings = builtins.fromTOML (builtins.readFile (./profiles/${profileInfo.profile}/settings.toml));
    
    # Merge the settings files. Profile settings override global settings.
    allSettings = nixpkgs.lib.recursiveUpdate globalSettings profileSettings;
    
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = allSettings.system;
    
    # ---- USER SETTINGS ---- #
    userSettings = allSettings.user;
    
    pkgs = import inputs.nixpkgs {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
    

  in {
    # This is the main output that builds your NixOS system.
    nixosConfigurations.system = nixpkgs.lib.nixosSystem {
      system = systemSettings.system;
      specialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
      };
      modules = [
        (./profiles/${systemSettings.profile}/configuration.nix) # load configuration.nix from selected PROFILE
        hyprland.nixosModules.default
      ];
    };
    homeConfigurations.user = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
      };
      modules = [
        (./profiles/${systemSettings.profile}/home.nix) # load home.nix from selected PROFILE
      ];
    };
  };
}
