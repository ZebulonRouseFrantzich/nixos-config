{ config, pkgs, ...}:
{
  imports = [
    ./opencode-agents-module.nix
  ];
  
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    
    agentManagement.source = ./agents;
  };
}
