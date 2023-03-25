{ pkgs, lib, ... }:

{
  imports = [ ../modules/base.nix ../modules/i3.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" "iwlwifi" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/25603dee-1358-453d-a2ca-ddd45b434f69";
      preLVM = true;
      allowDiscards = true;
    };
  };
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bumblebee.connectDisplay = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.throttled.enable = true;
  services.xserver.xkbOptions = "caps:escape";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/682b0eda-cb24-4e49-bc6b-752d5343300d";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/71CB-2C49";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/22bed2ce-ae58-4316-a3eb-11be58196c52"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.hostName = "saku-thinkpad";
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # services.xserver.videoDrivers = [ "nvidia" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

