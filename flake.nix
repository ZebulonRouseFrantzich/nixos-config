{
  description = "ZRF Core Flake";

  inputs = {
    # This pins your packages to a specific version of the nixpkgs repository.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, hyprland, ... }@inputs: 
  let
    lib = nixpkgs.lib;

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
    allSettings = lib.recursiveUpdate globalSettings profileSettings;
    
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

    # Helper function to help discover default.nix files for module construction.
    discoverDefaultsForModules = basePath:
      let
        # A recursive helper to find all relevant directory paths.
        findDirs = path:
          let
            entries = builtins.readDir path;
            isModule = builtins.pathExists (path + "/default.nix");
            currentDir = if isModule then [ path ] else [];
            subDirs = lib.flatten (lib.mapAttrsToList (name: type:
              if type == "directory" then findDirs (path + "/${name}") else []
            ) entries);
          in currentDir ++ subDirs;

        # Get the list of all module directory paths.
        # Example: [ ./user/app/neovim, ./user/shell/starship, ... ]
        modulePaths = findDirs basePath;
      in
        # Convert the list of paths into an attribute set.
        lib.listToAttrs (map (path: {
          # 'name' will be the directory's name, e.g., "neovim".
          name = lib.path.basename path;
          # 'value' is the path to the module directory itself.
          value = path;
        }) modulePaths);

  in {
    # This is the main output that builds your NixOS system.
    nixosConfigurations.system = lib.nixosSystem {
      system = systemSettings.system;
      specialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
      };
      modules = [
        (./profiles/${systemSettings.profile}/configuration.nix) # load configuration.nix from selected PROFILE
        nixos-wsl.nixosModules.default
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

    homeManagerModules = discoverDefaultsForModules ./user;
  };
}
