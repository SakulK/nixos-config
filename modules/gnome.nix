{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.layout = "pl";

  environment.systemPackages = with pkgs; [
    pop-gtk-theme
    pop-icon-theme
    gnome.gnome-tweak-tool
    gnome.gnome-shell-extensions
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.appindicator
    gnomeExtensions.system-monitor
    gnomeExtensions.gsconnect
  ];

  networking.firewall.allowedTCPPorts = [
    1716 # gsconnect
  ];
}
