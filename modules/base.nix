{ pkgs, home-manager, ... }:

let
  rofi-audio-sink = pkgs.writeScriptBin "rofi-audio-sink" ''
    #!${pkgs.stdenv.shell}
    sink=$(${pkgs.ponymix}/bin/ponymix -t sink list|awk '/^sink/ {s=$1" "$2;getline;gsub(/^ +/,"",$0);print s" "$0}'|rofi -dmenu -p 'pulseaudio sink:'|grep -Po '[0-9]+(?=:)') &&
    ${pkgs.ponymix}/bin/ponymix set-default -d $sink &&
    for input in $(${pkgs.ponymix}/bin/ponymix list -t sink-input|grep -Po '[0-9]+(?=:)');do
      echo "$input -> $sink"
      ${pkgs.ponymix}/bin/ponymix -t sink-input -d $input move $sink
    done
  '';
in {
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "lat2-16";
    keyMap = "pl";
    colors = [
      "1d2021"
      "cc241d"
      "98971a"
      "d79921"
      "458588"
      "b16286"
      "689d6a"
      "bdae93"
      "7c6f64"
      "fb4934"
      "b8bb26"
      "fabd2f"
      "83a598"
      "d3869b"
      "8ec07c"
      "ebdbb2"
    ];
  };

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      load-module module-switch-on-connect
      load-module module-switch-on-port-available
      load-module module-bluetooth-discover
      load-module module-bluetooth-policy
      load-module module-bluez5-discover
      load-module module-bluez5-device
    '';
  };
  hardware.bluetooth = {
    enable = true;
    settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
    disabledPlugins = [ "sap" ];
  };

  users.users.sakulk = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "vboxusers"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;
  };

  services.xserver.enable = true;
  services.xserver.dpi = 96;
  services.xserver.layout = "pl";
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = ./wallpaper.png;
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

  programs.light.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.users.sakulk = {
    home.file.".embedmongo/extracted/Linux-B64--4.0.2/extractmongod".source =
      "${pkgs.mongodb-4_0}/bin/mongod";

    home.sessionVariables = {
      EDITOR = "nvim";
      SBT_NATIVE_CLIENT = "true";
    };

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

    services.lorri.enable = true;

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.bat = {
      enable = true;
      config = { theme = "gruvbox-dark"; };
    };

    programs.vscode = {
      enable = true;
      extensions = (with pkgs.vscode-extensions; [
        justusadam.language-haskell
        haskell.haskell
        tamasfe.even-better-toml
        eamodio.gitlens
        usernamehw.errorlens
        matklad.rust-analyzer
        serayuzgur.crates
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "gruvbox";
          publisher = "jdinhlife";
          version = "1.5.0";
          sha256 = "sha256-b0BeAYtbZa0n3l55g0e6+74eoj8KWNxZVrteylcKtZE=";
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
      shellAliases = { cat = "bat -p"; };
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";
      defaultOptions = [
        "--reverse"
        "--color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f"
        "--color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54"
      ];
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [ "--preview='bat {} --color=always'" ];
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
          style = "bold #d79921";
        };
        character = {
          success_symbol = "[λ](bold blue)";
          error_symbol = "[λ](bold red)";
        };
        git_branch = {
          format = "[$symbol $branch ]($style)";
          symbol = "";
          style = "bold green";
        };
        git_status = {
          ahead = "[ﰵ$count](green)";
          behind = "ﰬ$count";
          modified = "[$count](yellow)";
          diverged = "ﰵﰬ";
          untracked = "⛔$count";
          staged = "[$count](green)";
          stashed = "[📦](yellow)";
        };
        format =
          "$directory$git_branch$git_commit$git_state$git_status$cmd_duration$character";
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
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
            family = "JetBrainsMono Nerd Font Mono";
            style = "Medium";
          };
          bold = {
            family = "JetBrainsMono Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font Mono";
            style = "Italic";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font Mono";
            style = "Bold Italic";
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
          font = "JetBrainsMono Nerd Font";
          geometry = "0x0-25+50";
          follow = "keyboard";
          alignment = "center";
          padding = 8;
          horizontal_padding = 8;
          browser = "${pkgs.firefox}/bin/firefox -new-tab";
          frame_width = 3;
          frame_color = "#928374";
          word_wrap = true;
          format = ''
            <b>%s</b>
            %b'';
          show_indicators = "yes";
          max_icon_size = 64;
        };
        urgency_low = {
          background = "#282828";
          foreground = "#a89984";
          timeout = 5;
        };

        urgency_normal = {
          background = "#282828";
          foreground = "#a89984";
          timeout = 10;
        };

        urgency_critical = {
          foreground = "#9d0006";
          background = "#282828";
          timeout = 0;
        };
      };
    };

    services.gammastep = {
      enable = true;
      tray = true;
      dawnTime = "6:00-7:45";
      duskTime = "17:00-19:00";
      temperature.day = 6500;
      temperature.night = 4000;
    };

    services.screen-locker = {
      enable = true;
      xautolock.detectSleep = false;
      lockCmd = "i3lock-fancy-rapid 10 3";
      inactiveInterval = 15;
    };

    # services.picom = {
    #   enable = true;
    #   fade = true;
    #   shadow = true;
    #   shadowExclude = ["focused = 0" "class_g = 'jetbrains-idea-ce'"];
    #   fadeDelta = 6;
    #   inactiveDim = "0.15";
    #   fadeExclude = ["class_g = 'jetbrains-idea-ce'"];
    #   extraOptions = ''
    #     unredir-if-possible = true;
    #     dbe = true;
    #     focus-exclude = ["class_g = 'jetbrains-idea-ce'"];
    #   '';
    # };

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
              dpi = 96;
            };
            HDMI-0 = {
              enable = true;
              primary = false;
              mode = "1920x1080";
              rate = "60.00";
              position = "0x0";
              crtc = 0;
              dpi = 96;
            };
          };
        };
      };
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        gruvbox-community
        nvim-colorizer-lua
        nvim-tree-lua
        vim-startify
        nvim-scrollview
        telescope-nvim
        plenary-nvim
        vim-rooter
        which-key-nvim
        nvim-web-devicons
        lualine-nvim
        gitsigns-nvim
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            tree-sitter-scala
            tree-sitter-nix
            tree-sitter-rust
          ]
        ))
      ];
      extraConfig = ''
        set hidden
        set nowrap
        set number relativenumber
        set mouse=a
        set termguicolors
        set nohlsearch
        set scrolloff=8
        set background=dark
        colorscheme gruvbox

        lua << EOF
        require'colorizer'.setup()
        require'which-key'.setup()
        require'lualine'.setup {
          options = {theme = 'gruvbox_material'}
        }
        require'nvim-tree'.setup()
        require'gitsigns'.setup {
          current_line_blame = true,
          numhl = true
        }

        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        }
        EOF

        let mapleader = " "
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      '';
    };
  };

  programs.java = {
    enable = true;
    package = pkgs.graalvm11-ce;
  };

  virtualisation.docker.enable = true;

  fonts.fonts = [ pkgs.nerdfonts ];

  environment.shells = with pkgs; [ bashInteractive zsh ];
  environment.variables = { WINIT_X11_SCALE_FACTOR = "1"; };
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
    ripgrep
    bottom
    hyperfine
    i3lock-fancy-rapid
    blueberry
    rofi-power-menu
    htop
    maim
    rofi-audio-sink
    gitui
    jq
    killall

    # benchmarking
    geekbench
    s-tui
    stress

    # haskell
    cabal-install
    stack

    # scala
    (sbt.override { jre = graalvm11-ce; })
    stable.jetbrains.idea-community

    #rust
    cargo
    rustc
    gcc

    # kubernetes
    kubectl
    kubectx

    docker-compose

    slack-dark
    keepassxc
    streamlink
  ];
}
