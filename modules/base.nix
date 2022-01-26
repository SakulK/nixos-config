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
in
{
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
    initialPassword = "password";
  };

  services.xserver.enable = true;
  services.xserver.dpi = 96;
  services.xserver.layout = "pl";
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = ./wallpaper.png;
    greeters.mini = {
      enable = true;
      user = "sakulk";
      extraConfig = ''
        [greeter]
        show-password-label = false
        [greeter-theme]
        error-color = "#ebdbb2"
        window-color = "#1d2021"
        border-color = "#1d2021"
        password-color = "#1d2021"
        password-background-color = "#d79921"
        password-border-color = "#1d2021"
      '';
    };
  };

  services.xserver.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
    };
  };

  programs.light.enable = true;
  programs.dconf.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.users.sakulk = {
    home.file.".embedmongo/extracted/Linux-B64--unknown---4.4.9/extractmongod".source =
      "${pkgs.mongodb-4_2}/bin/mongod";
    home.file.".icons/default".source =
      "${pkgs.numix-cursor-theme}/share/icons/Numix-Cursor-Light";

    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      SBT_NATIVE_CLIENT = "true";
    };

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
        tamasfe.even-better-toml
        eamodio.gitlens
        usernamehw.errorlens
        matklad.rust-analyzer
        serayuzgur.crates
        scalameta.metals
        scala-lang.scala
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "gruvbox";
        publisher = "jdinhlife";
        version = "1.5.0";
        sha256 = "sha256-b0BeAYtbZa0n3l55g0e6+74eoj8KWNxZVrteylcKtZE=";
      }];
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
        plugins = [ "git" "kubectl" "tmux" ];
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
        "desktop-single" = {
          fingerprint = {
            HDMI-0 =
              "00ffffffffffff000469ec2701010101091d0103803c22780eee91a3544c99260f505421080001010101010101010101010101010101565e00a0a0a029503020350056502100001a000000ff004b334c4d51533030363730310a000000fd00183c1e8c1e010a202020202020000000fc00524f47205047323739510a2020016502031ac147901f0413031201230907018301000065030c0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1";
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
      };
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        gruvbox-material
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
        indent-blankline-nvim-lua
        (nvim-treesitter.withPlugins (plugins:
          with plugins; [
            tree-sitter-scala
            tree-sitter-nix
            tree-sitter-rust
            tree-sitter-haskell
          ]))
        nvim-lspconfig
        nvim-autopairs
        bufferline-nvim
        comment-nvim
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
        cmp_luasnip
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
        set guifont=JetBrainsMono\ Nerd\ Font:h10
        set completeopt=menu,menuone,noselect

        lua << EOF
        vim.g.gruvbox_material_palette = "original"
        vim.cmd[[colorscheme gruvbox-material]]
        require'colorizer'.setup()
        require'which-key'.setup()
        require'lualine'.setup {
          options = {theme = 'gruvbox-material'}
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
        require'indent_blankline'.setup()
        require'nvim-autopairs'.setup()
        require'nvim-web-devicons'.setup {
          default = true;
        }
        require'bufferline'.setup()
        require'Comment'.setup()

        -- Setup nvim-cmp.
        local cmp = require'cmp'

        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
          },
          mapping = {
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ['<C-e>'] = cmp.mapping({
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
            }),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' }, -- For luasnip users.
          }, {
            { name = 'buffer' },
          })
        })

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline('/', {
          sources = {
            { name = 'buffer' }
          }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })

        -- Setup lspconfig.
        local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

        local nvim_lsp = require('lspconfig')

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
          local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
          local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

          -- Enable completion triggered by <c-x><c-o>
          buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Mappings.
          local opts = { noremap=true, silent=true }

          -- See `:help vim.lsp.*` for documentation on any of the below functions
          buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          buf_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)
          buf_set_keymap('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts)
          buf_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
          buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
          buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
          buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
          buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
          buf_set_keymap('n', '<space>cf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
          buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
          buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

        end

        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches
        local servers = { 'rust_analyzer', 'hls', 'rnix' }
        for _, lsp in ipairs(servers) do
          nvim_lsp[lsp].setup {
            on_attach = on_attach,
            flags = {
              debounce_text_changes = 150,
            },
            capabilities = capabilities
          }
        end
        EOF

        let mapleader = " "
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      '';
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "a";
      baseIndex = 1;
      newSession = true;
      historyLimit = 10000;
      terminal = "tmux-256color";
      extraConfig = ''
        set -g mouse on
        set-option -g renumber-windows on
        set -as terminal-features ",xterm-256color:RGB"
      '';
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = gruvbox;
          extraConfig = ''
            set -g @tmux-gruvbox 'dark'
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
    spotify
    vlc
    nixfmt
    rnix-lsp
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
    neovide
    xclip
    graphviz
    gnome.baobab
    gnome.eog
    gnome.nautilus
    gnome.simple-scan
    gnome.gnome-control-center
    gnome.gnome-disk-utility
    evince

    # benchmarking
    geekbench
    s-tui
    stress

    # haskell
    ghc
    cabal-install
    stack
    haskell-language-server
    ormolu

    # scala
    (sbt.override { jre = graalvm11-ce; })
    jetbrains.idea-community
    (ammonite.override { jre = graalvm11-ce; })

    #rust
    cargo
    rustc
    gcc
    rust-analyzer

    # kubernetes
    kubectl
    kubectx

    docker-compose

    slack-dark
    keepassxc
    streamlink
  ];
}
