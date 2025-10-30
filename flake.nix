{
  description = "ZRF Core Flake";

  inputs = {
    # This pins your packages to a specific version of the nixpkgs repository.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nixCats, hyprland, ... }@inputs: 
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

    homeManagerModules = {
      git = import ./user/app/git;
      lazygit = import ./user/app/lazygit;
      neovim = (import ./user/app/neovim) { inherit nixCats; };
      wezterm = import ./user/app/terminal/wezterm;
      bash = import ./user/shell/bash;
      starship = import ./user/shell/starship;
      tmux = import ./user/shell/tmux;
      hyprland = import ./user/wm/hyprland;
      direnv = import ./user/shell/direnv;
      opencode = import ./user/app/ai/opencode;
      claude-code = import ./user/app/ai/claude-code;
      claude-code-agents = import ./user/app/ai/claude-code/agents;
    };

  in {
    # This is the main output that builds your NixOS system.
    nixosConfigurations.system = lib.nixosSystem {
      system = systemSettings.system;
      specialArgs = {
        inherit systemSettings;
        inherit userSettings;
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
        inherit homeManagerModules;
      };
      modules = [
        (./profiles/${systemSettings.profile}/home.nix) # load home.nix from selected PROFILE
      ];
    };

    inherit homeManagerModules;
  };
}
