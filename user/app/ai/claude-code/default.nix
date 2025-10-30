{ pkgs, ...}:
let
  fullstack-developer = import ./agents/fullstack-developer.nix;
in
{
  home.packages = with pkgs; [
    claude-code
  ];

  programs.claude-code = {
    enable = true;
    agents = {
      fullstack-developer = fullstack-developer.agentInfo;
    };
  };
}
