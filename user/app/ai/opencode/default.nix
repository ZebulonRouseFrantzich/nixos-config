{ pkgs, ...}:
{
  home.packages = with pkgs; [
    opencode
  ];

  programs.opencode = {
    enable = true;
  };
}
