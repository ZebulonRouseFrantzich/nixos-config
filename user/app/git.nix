{ pkgs, ...}:
{
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    userName = "Zebulon Rouse-Frantzich";
    userEmail = "zebulonfrantzich@gmail.com";
  };
}
