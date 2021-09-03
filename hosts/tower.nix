{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../modules/base.nix
    ../modules/gnome.nix
    ../modules/printer.nix
    ../modules/i3.nix
  ];

  powerManagement.cpuFreqGovernor = "ondemand";
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.gfxpayloadBios = "keep";
  boot.loader.grub.gfxmodeBios = "1920x1080";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig =
    "options hid_apple fnmode=2"; # enable F keys for Keychron K2

  networking.hostName = "saku-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.minidlna = {
    enable = true;
    mediaDirs = [ "/dlna" ];
    announceInterval = 60;
  };
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [ qbittorrent kdenlive ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  networking.firewall.allowedTCPPorts = [
    8200 # minidlna
    8010 # vlc chromecast renderer
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
