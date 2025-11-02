{ config, pkgs, ...}:
{
  home.packages = with pkgs; [
    opencode
  ];

  home.file."${config.xdg.configHome}/opencode/agent" = {
    source = ./agents;
    recursive = true;
  };

  programs.opencode = {
    enable = true;
  };
}
