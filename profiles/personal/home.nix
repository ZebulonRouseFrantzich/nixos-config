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
  #
  # programs.opencode.agentManagement.overrides = {
  #   deep-plan = {
  #     model = "anthropic/claude-sonnet-4-20250514";
  #     temperature = 0.5;
  #   };
  #   code-reviewer = {
  #     model = "anthropic/claude-sonnet-4-20250514";
  #   };
  #   spec-writer = {
  #     model = "anthropic/claude-sonnet-4-20250514";
  #   };
  #   security-auditor = {
  #     model = "anthropic/claude-sonnet-4-20250514";
  #   };
  # };
  
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
