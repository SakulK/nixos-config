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

  home-manager.useGlobalPkgs = true;
  home-manager.users.sakulk = {
    home.file.".embedmongo/extracted/Linux-B64--4.0.2/extractmongod".source =
      "${pkgs.mongodb-4_0}/bin/mongod";

    dconf.settings = import ./dconf.nix;

    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.pop-icon-theme;
        name = "Pop";
      };
      theme = {
        package = pkgs.pop-gtk-theme;
        name = "Pop-dark";
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
        bbenoist.Nix
        justusadam.language-haskell
        haskell.haskell
        scala-lang.scala
        tamasfe.even-better-toml
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "theme-dracula";
          publisher = "dracula-theme";
          version = "2.22.4";
          sha256 = "sha256-SCtTkyXUCHgGrpTyTkTbO+iBJjd+LK19BcWHVNpmGDQ=";
        }
        {
          name = "metals";
          publisher = "scalameta";
          version = "1.10.7";
          sha256 = "sha256-3KPfi8LW+hbQmF8yjI1ULhcC/WkZGxpPpc075UixISw=";
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
      shellAliases = { icat = "kitty +kitten icat"; };
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

    programs.kitty = {
      enable = true;
      keybindings = {
        "kitty_mod+t" = "new_tab_with_cwd";
        "kitty_mod+enter" = "new_window_with_cwd";
      };
      extraConfig = ''
        enabled_layouts       Vertical, Stack
        window_margin_width   2
        inactive_text_alpha   0.5
        background_opacity    0.9
        background            #1d1d1d
        foreground            #f7f6ec
        cursor                #eccf4f
        color0                #343835
        color8                #585a58
        color1                #ce3e60
        color9                #d18ea6
        color2                #7bb75b
        color10               #767e2b
        color3                #e8b32a
        color11               #77592e
        color4                #4c99d3
        color12               #135879
        color5                #a57fc4
        color13               #5f4190
        color6                #389aac
        color14               #76bbca
        color7                #f9faf6
        color15               #b1b5ae
        selection_background  #165776
        selection_foreground  #1d1d1d
      '';
      font.name = "JetBrainsMono Nerd Font";
    };

    programs.alacritty = {
      enable = true;
      settings = {
        background_opacity = 0.8;
        colors = {
          primary = {
            background = "#111111";
            foreground = "#f7f6ec";
          };
          normal = {
            black = "#343835";
            red = "#ce3e60";
            green = "#7bb75b";
            yellow = "#e8b32a";
            blue = "#4c99d3";
            magenta = "#a57fc4";
            cyan = "#389aac";
            white = "#f9faf6";
          };
          bright = {
            black = "#585a58";
            red = "#d18ea6";
            green = "#767e2b";
            yellow = "#77592e";
            blue = "#135879";
            magenta = "#5f4190";
            cyan = "#76bbca";
            white = "#b1b5ae";
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
    streamlink
  ];
}
