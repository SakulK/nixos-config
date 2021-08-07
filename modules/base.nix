{ pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "0423a7b40cd29aec0bb02fa30f61ffe60f5dfc19";
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

  services.xserver.enable = true;
  services.xserver.layout = "pl";
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = ./wallpaper.jpg;
    greeters.gtk = {
      theme = {
        package = pkgs.gruvbox-dark-gtk;
        name = "gruvbox-dark";
      };
      iconTheme = {
        package = pkgs.gruvbox-dark-icons-gtk;
        name = "gruvbox-dark";
      };
    };
  };

  services.xserver.libinput.mouse = {
    accelProfile = "flat";
    accelSpeed = "0";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.sakulk = {
    home.file.".embedmongo/extracted/Linux-B64--4.0.2/extractmongod".source =
      "${pkgs.mongodb-4_0}/bin/mongod";

    dconf.settings = import ./dconf.nix;

    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.gruvbox-dark-gtk;
        name = "gruvbox-dark";
      };
      theme = {
        package = pkgs.gruvbox-dark-icons-gtk;
        name = "gruvbox-dark";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.vscode = {
      enable = true;
      extensions = (with pkgs.vscode-extensions; [
        bbenoist.nix
        justusadam.language-haskell
        haskell.haskell
        scala-lang.scala
        tamasfe.even-better-toml
        naumovs.color-highlight
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "gruvbox";
          publisher = "jdinhlife";
          version = "1.5.0";
          sha256 = "sha256-b0BeAYtbZa0n3l55g0e6+74eoj8KWNxZVrteylcKtZE=";
        }
        {
          name = "metals";
          publisher = "scalameta";
          version = "1.10.8";
          sha256 = "sha256-tr/942FRrJMA/0UAIpfMXERUeQ91l8Fjsqaua1VECVc=";
        }
      ];
      keybindings = [{
        key = "ctrl+d";
        command = "editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
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
          success_symbol = "[](blue)";
          error_symbol = "[](red)";
        };
        git_branch = {
          format = "[$symbol $branch ]($style)";
          symbol = "";
          style = "bold green";
        };
        git_status = {
          ahead = "[$count](green)";
          behind = "$count";
          modified = "[🔶$count](yellow)";
          untracked = "⛔$count";
          staged = "[✅$count](green)";
          stashed = "📦";
        };
        format =
          "$directory$git_branch$git_commit$git_state$git_status$cmd_duration$character";
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        background_opacity = 0.8;
        colors = {
          primary = {
            background = "#282828";
            foreground = "#ebdbb2";
            bright_foreground = "#fbf1c7";
            dim_foreground = "#a89984";
          };
          bright = {
            black = "#928374";
            red = "#fb4934";
            green = "#b8bb26";
            yellow = "#fabd2f";
            blue = "#83a598";
            magenta = "#d3869b";
            cyan = "#8ec07c";
            white = "#ebdbb2";

          };
          normal = {
            black = "#282828";
            red = "#cc241d";
            green = "#98971a";
            yellow = "#d79921";
            blue = "#458588";
            magenta = "#b16286";
            cyan = "#689d6a";
            white = "#a89984";
          };
          dim = {
            black = "#32302f";
            red = "#9d0006";
            green = "#79740e";
            yellow = "#b57614";
            blue = "#076678";
            magenta = "#8f3f71";
            cyan = "#427b58";
            white = "#928374";
          };
        };
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Medium";
          };
          size = 10;
        };
        selection.save_to_clipboard = true;
        window = {
          padding = {
            x = 5;
            y = 5;
          };
        };
      };
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          geometry = "300x50-15+49";
          follow = "keyboard";
          transparency = 5;
          padding = 5;
          browser = "${pkgs.firefox}/bin/firefox -new-tab";
          frame_width = 3;
          frame_color = "#8EC07C";
        };
        urgency_low = {
          frame_color = "#3B7C87";
          foreground = "#3B7C87";
          background = "#191311";
          timeout = 4;
        };

        urgency_normal = {
          frame_color = "#5B8234";
          foreground = "#5B8234";
          background = "#191311";
          timeout = 6;
        };

        urgency_critical = {
          frame_color = "#B7472A";
          foreground = "#B7472A";
          background = "#191311";
          timeout = 8;
        };
      };
    };

    services.gammastep = {
      enable = true;
      tray = true;
      dawnTime = "6:00-7:45";
      duskTime = "20:00-21:00";
      temperature.day = 6500;
      temperature.night = 4500;
    };

    services.screen-locker = {
      enable = true;
      lockCmd = "i3lock-fancy-rapid 10 3";
      inactiveInterval = 15;
    };

    services.picom = {
      enable = true;
      fade = true;
      fadeDelta = 3;
      inactiveDim = "0.1";
    };

    programs.rofi = {
      enable = true;
      theme = "gruvbox-dark-hard";
      plugins = [ pkgs.rofi-power-menu ];
    };

    programs.autorandr = {
      enable = true;
      profiles = {
        "desktop" = {
          fingerprint = {
            DP-0 =
              "00ffffffffffff000469ec272d1a0000091d0104a53c227806ee91a3544c99260f505421080001010101010101010101010101010101565e00a0a0a029503020350056502100001a000000ff002341534f6e796b793363454864000000fd001e9022de3b010a202020202020000000fc00524f47205047323739510a202001d2020312412309070183010000654b040001015a8700a0a0a03b503020350056502100001a5aa000a0a0a046503020350056502100001a6fc200a0a0a055503020350056502100001a22e50050a0a0675008203a0056502100001e1c2500a0a0a011503020350056502100001a0000000000000000000000000000000000000019";
            HDMI-0 =
              "00ffffffffffff0015c35624010101012c17010380351e78ea219da35a52a026144b54a54b003168317c4568457c6168617c8180d1c0023a801871382d40582c45000a262100001e000000ff0032373230353130330a20202020000000fd00177a0f640f000a202020202020000000fc004647323432310a202020202020019c020326f14f901f05140413031202110716061520230907078301000066030c00100080e2007b011d8018711c1620582c25000a262100009e011d80d0721c1620102c25800a262100009e8c0ad08a20e02d10103e96000a26210000188c0ad090204031200c4055000a26210000180000000000000000000000000000000000d8";
          };
          config = {
            DP-0 = {
              enable = true;
              primary = true;
              mode = "2560x1440";
              rate = "144.00";
              position = "1920x0";
              crtc = 1;
            };
            HDMI-0 = {
              enable = true;
              primary = false;
              mode = "1920x1080";
              rate = "60.00";
              position = "0x0";
              crtc = 0;
            };
          };
        };
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

  fonts.fonts = [ pkgs.nerdfonts ];

  environment.shells = with pkgs; [ bashInteractive zsh ];
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
    i3lock-fancy-rapid
    blueberry
    rofi-power-menu
    htop
    maim

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

    docker-compose

    slack-dark
    keepassxc
    streamlink
  ];
}
