{ pkgs, ... }:

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
    wholroyd.jinja
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
    name = "theme-dracula";
    publisher = "dracula-theme";
    version = "2.22.3";
    sha256 = "0wni9sriin54ci8rly2s68lkfx8rj1cys6mgcizvps9sam6377w6";
  }];
  custom-vscode =
    pkgs.vscode-with-extensions.override { vscodeExtensions = extensions; };
in {
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth.enable = true;

  users.users.sakulk = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "vboxusers"
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    firefox
    google-chrome
    custom-vscode
    spotify
    vlc
    any-nix-shell
    nixfmt
    terminator
    (callPackage ../modules/lcat.nix { })
    fd
    sd
    dua
    bat
    exa
    hyperfine

    zsh-powerlevel10k

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
  ];
  fonts.fonts = with pkgs;
    [
      meslo-lgs-nf # powerlevel10k font
    ];

  virtualisation.docker.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.graalvm11-ce;
  };
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
}

