{ pkgs, userSettings, ...}:
{
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = userSettings.name;
      email = userSettings.email;
    };
  };
}
