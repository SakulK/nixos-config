{ pkgs, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;

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
