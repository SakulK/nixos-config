{ pkgs, ... }:

let
  rofi-audio-sink = pkgs.writeShellApplication {
    name = "rofi-audio-sink";
    runtimeInputs = [
      pkgs.ponymix
      pkgs.rofi
    ];
    text = builtins.readFile ./scripts/rofi-audio-sink.sh;
  };
  rofi-audio-source = pkgs.writeShellApplication {
    name = "rofi-audio-source";
    runtimeInputs = [
      pkgs.ponymix
      pkgs.rofi
    ];
    text = builtins.readFile ./scripts/rofi-audio-source.sh;
  };
in
{
  nix.settings.trusted-users = [
    "root"
    "sakulk"
  ];
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

  systemd.services.NetworkManager-wait-online.enable = false;
  networking.dhcpcd.wait = "background";
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
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
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
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
    initialPassword = "password";
  };

  services.xserver.enable = true;
  services.xserver.dpi = 96;
  services.xserver.xkb.layout = "pl";
  services.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = ./wallpaper.png;
    greeters.gtk = {
      enable = true;
      theme = {
        package = pkgs.stable.gruvbox-gtk-theme;
        name = "Gruvbox-Dark-BL-LB";
      };
      cursorTheme = {
        package = pkgs.numix-cursor-theme;
        name = "Numix-Cursor-Light";
      };
    };
    # greeters.mini = {
    #   enable = true;
    #   user = "sakulk";
    #   extraConfig = ''
    #     [greeter]
    #     show-password-label = false
    #     [greeter-theme]
    #     error-color = "#ebdbb2"
    #     window-color = "#1d2021"
    #     border-color = "#1d2021"
    #     password-color = "#1d2021"
    #     password-background-color = "#d79921"
    #     password-border-color = "#1d2021"
    #   '';
    # };
  };

  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
    };
  };

  services.udev.packages = [
    pkgs.chrysalis
    pkgs.bazecor
  ];
  services.fwupd.enable = true;

  services.autorandr = {
    enable = true;
    profiles = {
      "desktop" = {
        fingerprint = {
          DP-0 = "00ffffffffffff000469ec272d1a0000091d0104a53c227806ee91a3544c99260f505421080001010101010101010101010101010101565e00a0a0a029503020350056502100001a000000ff002341534f6e796b793363454864000000fd001e9022de3b010a202020202020000000fc00524f47205047323739510a202001d2020312412309070183010000654b040001015a8700a0a0a03b503020350056502100001a5aa000a0a0a046503020350056502100001a6fc200a0a0a055503020350056502100001a22e50050a0a0675008203a0056502100001e1c2500a0a0a011503020350056502100001a0000000000000000000000000000000000000019";
          HDMI-0 = "00ffffffffffff0015c35624010101012c17010380351e78ea219da35a52a026144b54a54b003168317c4568457c6168617c8180d1c0023a801871382d40582c45000a262100001e000000ff0032373230353130330a20202020000000fd00177a0f640f000a202020202020000000fc004647323432310a202020202020019c020326f14f901f05140413031202110716061520230907078301000066030c00100080e2007b011d8018711c1620582c25000a262100009e011d80d0721c1620102c25800a262100009e8c0ad08a20e02d10103e96000a26210000188c0ad090204031200c4055000a26210000180000000000000000000000000000000000d8";
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
      "desktop-single-hdmi" = {
        fingerprint = {
          HDMI-0 = "00ffffffffffff000469ec2701010101091d0103803c22780eee91a3544c99260f505421080001010101010101010101010101010101565e00a0a0a029503020350056502100001a000000ff004b334c4d51533030363730310a000000fd00183c1e8c1e010a202020202020000000fc00524f47205047323739510a2020016502031ac147901f0413031201230907018301000065030c0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1";
        };
        config = {
          HDMI-0 = {
            enable = true;
            primary = true;
            mode = "2560x1440";
            rate = "60.00";
            position = "0x0";
            crtc = 1;
            dpi = 96;
          };
        };
      };
      "desktop-single-dp" = {
        fingerprint = {
          DP-0 = "00ffffffffffff000469ec272d1a0000091d0104a53c227806ee91a3544c99260f505421080001010101010101010101010101010101565e00a0a0a029503020350056502100001a000000ff002341534f6e796b793363454864000000fd001e9022de3b010a202020202020000000fc00524f47205047323739510a202001d2020312412309070183010000654b040001015a8700a0a0a03b503020350056502100001a5aa000a0a0a046503020350056502100001a6fc200a0a0a055503020350056502100001a22e50050a0a0675008203a0056502100001e1c2500a0a0a011503020350056502100001a0000000000000000000000000000000000000019";
        };
        config = {
          DP-0 = {
            enable = true;
            primary = true;
            mode = "2560x1440";
            rate = "144.00";
            position = "0x0";
            crtc = 1;
            dpi = 96;
          };
        };
      };
    };
  };

  services.fstrim.enable = true;
  services.udisks2.enable = true;

  programs.light.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.kdeconnect.enable = true;
  programs.ssh = {
    startAgent = true;
    agentTimeout = "8h";
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "32768";
    }
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.users.sakulk = {
    home.stateVersion = "22.11";
    home.file.".icons/default".source = "${pkgs.numix-cursor-theme}/share/icons/Numix-Cursor-Light";

    home.sessionVariables = {
      TERMINAL = "alacritty";
      SBT_NATIVE_CLIENT = "true";
    };

    xsession.enable = true;

    gtk = {
      enable = true;
      theme = {
        package = pkgs.stable.gruvbox-gtk-theme;
        name = "Gruvbox-Dark-BL-LB";
      };
    };

    programs.git = {
      enable = true;
      userName = "Łukasz Krenski";
      userEmail = "sakulk@gmail.com";
      delta = {
        enable = true;
        options = {
          syntax-theme = "gruvbox-dark";
          line-numbers = true;
          minus-style = "syntax #613c3e";
          plus-style = "syntax #293f2a";
        };
      };
      extraConfig = {
        merge.conflictstyle = "diff3";
        rerere.enabled = true;
        rebase.updateRefs = true;
      };
    };

    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    services.udiskie.enable = true;

    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    programs.eza = {
      enable = true;
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
      };
    };

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      initExtra = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "kubectl"
          "tmux"
          "bazel"
        ];
      };
      plugins = [
        {
          name = "fast-syntax-highlighting";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
      ];
      shellAliases = {
        cat = "bat -p";
        kcx = "kubectx";
        gcof = "git checkout $(git branch --sort=-committerdate | fzf)";
      };
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
          ahead = "[󰜷$count](green)";
          behind = "󰜮$count";
          modified = "[!$count](yellow)";
          diverged = "󰜷󰜮";
          untracked = "⛔$count";
          staged = "[$count](green)";
          stashed = "[󰏗](yellow)";
        };
        kubernetes = {
          disabled = false;
          format = "[$symbol$context \\($namespace\\) ]($style)";
          contexts = [
            {
              context_pattern = ".*-ci.*";
              context_alias = "ci";
            }
            {
              context_pattern = ".*-dev.*";
              context_alias = "dev";
            }
            {
              context_pattern = ".*-stage.*";
              context_alias = "stage";
            }
            {
              context_pattern = ".*-prod.*";
              context_alias = "prod";
            }
          ];
        };
        format = "$directory$git_branch$git_commit$git_state$git_status$kubernetes$cmd_duration$character";
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        env = {
          TERM = "xterm-256color";
        };
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

    programs.rofi = {
      enable = true;
      theme = "gruvbox-dark-hard";
      plugins = [ pkgs.rofi-power-menu ];
    };

    home.file.".config/nvim/lua".source = ./neovim/lua;
    programs.neovim = {
      enable = true;
      vimAlias = true;
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [
        gruvbox-material
        nvim-colorizer-lua
        nvim-tree-lua
        nvim-scrollbar
        telescope-nvim
        plenary-nvim
        vim-rooter
        which-key-nvim
        nvim-web-devicons
        lualine-nvim
        gitsigns-nvim
        indent-blankline-nvim-lua
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            tree-sitter-scala
            tree-sitter-nix
            tree-sitter-rust
            tree-sitter-haskell
            tree-sitter-lua
          ]
        ))
        nvim-lspconfig
        nvim-autopairs
        comment-nvim
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp-nvim-lsp-signature-help
        luasnip
        cmp_luasnip
        fidget-nvim
        nvim-metals
        alpha-nvim
        crates-nvim
        vim-illuminate
        vim-fugitive
      ];
      extraLuaConfig = ''require "user.init"'';
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "a";
      baseIndex = 1;
      newSession = true;
      historyLimit = 10000;
      terminal = "tmux-256color";
      escapeTime = 0;
      extraConfig = ''
        set -g mouse on
        set-option -g renumber-windows on
        set -as terminal-features ",xterm-256color:RGB"
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind-key -Tcopy-mode-vi MouseDragEnd1Pane send -X copy-selection
      '';
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = gruvbox;
          extraConfig = ''
            set -g @tmux-gruvbox 'dark'
            set -g window-style 'bg=color236'
            set -g window-active-style 'bg=black'
          '';
        }
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
          '';
        }
      ];
    };

    programs.chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        { id = "ihennfdbghdiflogeancnalflhgmanop"; } # gruvbox
        { id = "gcbommkclmclpchllfjekcdonpmejbdp"; } # https everywhere
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # dark reader
      ];
    };
  };

  programs.java = {
    enable = true;
    package = pkgs.graalvm-ce;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  fonts.packages = [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];
  environment.variables = {
    WINIT_X11_SCALE_FACTOR = "1";
  };
  environment.systemPackages = with pkgs; [
    wget
    git
    firefox
    spotify
    vlc
    nixfmt-rfc-style
    nil
    lcat
    fd
    sd
    dua
    ripgrep
    bottom
    procs
    hyperfine
    i3lock-fancy-rapid
    rofi-power-menu
    htop
    maim # screenshots
    rofi-audio-sink
    rofi-audio-source
    gitui
    jq
    xclip
    mate.eom # image viewer
    cinnamon.nemo-with-extensions # file manager
    gnome.simple-scan
    gnome.gnome-disk-utility
    gnome.file-roller
    evince # document viewer
    dig
    csview
    chrysalis
    bazecor
    nvd
    cachix
    usbutils

    # benchmarking
    # geekbench
    s-tui
    stress

    # scala
    (sbt.override { jre = graalvm-ce; })
    scala-cli
    stable.jetbrains.idea-community
    coursier
    metals

    # kubernetes
    kubectl
    kubectx

    docker-compose

    slack
    keepassxc
  ];
}
