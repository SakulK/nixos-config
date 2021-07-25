{ pkgs, ... }:

{
  services.xserver.windowManager.leftwm.enable = true;

  environment.systemPackages = with pkgs; [ feh polybar rofi picom ];

  home-manager.users.sakulk = {
    home.file.".config/leftwm/themes/current" = {
      source = ./theme;
      recursive = true;
    };
    home.file.".config/leftwm/config.toml".source = ./config.toml;
  };

}
