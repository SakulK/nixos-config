{ pkgs, ... }:

{
  services.xserver.windowManager.leftwm.enable = true;

  environment.systemPackages = with pkgs; [ feh polybarFull picom blueberry rofi-power-menu ];

  home-manager.users.sakulk = {
    home.file.".config/leftwm/themes/current" = {
      source = ./theme;
      recursive = true;
    };
    home.file.".config/leftwm/config.toml".source = ./config.toml;

    programs.rofi = {
        enable = true;
        theme = "gruvbox-dark-hard";
        plugins = [ pkgs.rofi-power-menu ];
    };
  };

}
