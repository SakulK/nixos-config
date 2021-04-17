# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
    bbenoist.Nix
    justusadam.language-haskell
    haskell.haskell
    scalameta.metals
    scala-lang.scala
    redhat.vscode-yaml
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
    name = "theme-dracula";
    publisher = "dracula-theme";
    version = "2.22.3";
    sha256 = "0wni9sriin54ci8rly2s68lkfx8rj1cys6mgcizvps9sam6377w6";
  }];
  custom-vscode =
    pkgs.vscode-with-extensions.override { vscodeExtensions = extensions; };

  printerIp = "192.168.1.13";
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  powerManagement.cpuFreqGovernor = "ondemand";
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig =
    "options hid_apple fnmode=2"; # enable F keys for Keychron K2

  # for droidcam
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" "snd-aloop" ];

  networking.hostName = "saku-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Configure keymap in X11
  services.xserver.layout = "pl";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.printers.ensurePrinters = [{
    name = "DCP-T710W";
    model = "everywhere";
    deviceUri = "ipp://${printerIp}/";
  }];

  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "DCP-T710W";
          ip = printerIp;
        };
      };
    };
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  hardware.bluetooth.enable = true;

  services.minidlna = {
    enable = true;
    mediaDirs = [ "/dlna" ];
    announceInterval = 60;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sakulk = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "vboxusers"
    ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    firefox
    google-chrome
    custom-vscode
    spotify
    qbittorrent
    vlc
    any-nix-shell
    nixfmt
    terminator
    (callPackage ./lcat.nix { })
    fd
    sd
    dua
    bat
    exa
    hyperfine

    zsh-powerlevel10k

    dracula-theme
    gnome3.gnome-tweaks
    gnome3.gnome-shell-extensions
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.appindicator
    gnomeExtensions.system-monitor
    gnomeExtensions.gsconnect

    # benchmarking
    geekbench
    s-tui
    stress

    # haskell
    cabal-install
    stack

    # scala
    (sbt.override { jre = graalvm11-ce; })
    jetbrains.idea-community

    # kubernetes
    kubectl
    kubectx
    kubernetes-helm

    docker-compose

    slack-dark
    keepassxc
    kdenlive
    droidcam
    mongodb-4_0
  ];
  fonts.fonts = with pkgs;
    [
      meslo-lgs-nf # powerlevel10k font
    ];

  programs.java = {
    enable = true;
    package = pkgs.graalvm11-ce;
  };

  programs.steam.enable = true;

  virtualisation.docker.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      any-nix-shell zsh --info-right | source /dev/stdin
    '';

    ohMyZsh = {
      enable = true;
      plugins = [ "git" "docker" "docker-compose" "kubectl" ];
    };
  };

  environment.shellAliases = {
    ls = "exa";
    la = "exa -la";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8200 # minidlna
    1716 # gsconnect
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

