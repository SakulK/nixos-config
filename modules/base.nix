{ pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "614a5b55bf46673c174dd3775e7fb1d6f9e14dfa";
    ref = "master";
  };
in {
  imports = [ (import "${home-manager}/nixos") ];

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

  home-manager.useGlobalPkgs = true;
  home-manager.users.sakulk = {
    home.file.".embedmongo/extracted/Linux-B64--4.0.2/extractmongod".source =
      "${pkgs.mongodb-4_0}/bin/mongod";

    programs.direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.vscode = {
      enable = true;
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
    };

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      initExtra = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" ];
      };
      plugins = [{
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }];
      shellAliases = {
        icat = "kitty +kitten icat";
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        line_break.disabled = true;
        directory = {
          truncate_to_repo = false;
          truncation_length = 5;
        };
        character = {
          success_symbol = "[λ](bold green)";
          error_symbol = "[✗](bold red)";
        };
        format =
          "$directory$git_branch$git_commit$git_state$git_status$cmd_duration$character";
      };
    };

    programs.kitty = {
      enable = true;
      keybindings = {
        "kitty_mod+t" = "new_tab_with_cwd";
        "kitty_mod+enter" = "new_window_with_cwd";
      };
      extraConfig = ''
        enabled_layouts       Vertical, Stack
        window_padding_width  3
        inactive_text_alpha   0.5
        background_opacity    0.9
        background            #161423
        foreground            #9e9ea0
        cursor                #a188f7
        color0                #2d283e
        color8                #58506a
        color1                #ec2160
        color9                #f0719a
        color2                #1fa91b
        color10               #52a95d
        color3                #8ddc1f
        color11               #b2dc87
        color4                #487cf4
        color12               #a9bbeb
        color5                #8c35c8
        color13               #ac81c1
        color6                #3added
        color14               #9ce3ea
        color7                #9e9ea0
        color15               #a188f7
        selection_background  #483d70
        selection_foreground  #161423
      '';
      font = {
        package = pkgs.meslo-lgs-nf;
        name = "MesloLGS NF";
      };
    };
  };

  programs.java = {
    enable = true;
    package = pkgs.graalvm11-ce;
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    firefox
    google-chrome
    spotify
    vlc
    nixfmt
    (callPackage ../modules/lcat.nix { })
    fd
    sd
    dua
    bat
    hyperfine

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
}
