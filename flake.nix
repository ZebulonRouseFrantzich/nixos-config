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
    allSettings = builtins.fromTOML (builtins.readFile ./system-and-user-settings.toml);

    # ---- SYSTEM SETTINGS ---- #
    systemSettings = allSettings.system;
    #{
    #  system = "x86_64-linux"; # system arch
    #  hostname = "wilder-laptop"; # hostname
    #  profile = "personal"; # select a profile defined from my profiles directory
    #  timezone = "America/Chicago"; # select timezone
    #  locale = "en_US.UTF-8"; # select locale
    #};

    # ---- USER SETTINGS ---- #
    userSettings = allSettings.user;
    #{
    #  username = "zrf"; # username
    #  name = "Zebulon Rouse-Frantzich"; # name/identifier
    #  email = "zebulonfrantzich@gmail.com"; # email (used for certain configurations)
    #  dotfilesDir = "~/nixos-config"; # absolute path of the local repo
    #  #theme = "io"; # selcted theme from my themes directory (./themes/)
    #  #wm = "hyprland"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
    #  # window manager type (hyprland or x11) translator
    #  #wmType = if ((wm == "hyprland") || (wm == "plasma")) then "wayland" else "x11";
    #  #browser = "qutebrowser"; # Default browser; must select one from ./user/app/browser/
    #  #spawnBrowser = if ((browser == "qutebrowser") && (wm == "hyprland")) then "qutebrowser-hyprprofile" else (if (browser == "qutebrowser") then "qutebrowser --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag num-raster-threads=4" else browser); # Browser spawn command must be specail for qb, since it doesn't gpu accelerate by default (why?)
    #  #defaultRoamDir = "Personal.p"; # Default org roam directory relative to ~/Org
    #  term = "wezterm"; # Default terminal command;
    #  #font = "Intel One Mono"; # Selected font
    #  #fontPkg = pkgs.intel-one-mono; # Font package
    #  editor = "nvim"; # Default editor;
    #};
    
    # PREVIOUS WAY - pkgs = nixpkgs.legacyPackages.${systemSettings.system};
    pkgs = import inputs.nixpkgs {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
  in {
    # This is the main output that builds your NixOS system.
    # 'nixos' should match your system's hostname.
    nixosConfigurations.system = nixpkgs.lib.nixosSystem {
      system = systemSettings.system;
      specialArgs = {
        inherit systemSettings;
        inherit userSettings;
        inherit inputs;
      };
      modules = [
        (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix") # load configuration.nix from selected PROFILE
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
        (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix") # load home.nix from selected PROFILE
      ];
    };
  };
}
