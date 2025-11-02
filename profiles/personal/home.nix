{ config, pkgs, userSettings, homeManagerModules, ... }:
{
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;
  programs.home-manager.enable = true;
  
  imports = with homeManagerModules; [
    bash
    git
    starship
    tmux
    wezterm
    direnv
    neovim
    lazygit
    opencode
  ];
  
  home.sessionVariables = {
    EDITOR = userSettings.editor;
    TERM = userSettings.term;
  };

  # Example of overriding the opencode agent values:
  # programs.opencode.agentManagement.overrides = {
  #   deep-plan = {
  #     model = "anthropic/claude-sonnet-4-5";
  #     temperature = 0.5;
  #   };
  # };

  programs.opencode.agentManagement.overrides = {
    deep-plan = {
      model = "anthropic/claude-sonnet-4-5";
      temperature = 0.5;
    };
  };

  home.stateVersion = "25.05"; # Don't change me without researching
}
