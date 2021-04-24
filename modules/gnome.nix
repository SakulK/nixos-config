{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.layout = "pl";

  environment.systemPackages = with pkgs; [
    dracula-theme
    gnome3.gnome-tweaks
    gnome3.gnome-shell-extensions
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.appindicator
    gnomeExtensions.system-monitor
    gnomeExtensions.gsconnect
  ];

  networking.firewall.allowedTCPPorts = [
    1716 # gsconnect
  ];
}
