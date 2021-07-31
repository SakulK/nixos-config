{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.layout = "pl";

  environment.systemPackages = with pkgs; [
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
