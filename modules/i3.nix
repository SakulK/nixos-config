{ pkgs, lib, ... }:

let modifier = "Mod4";
in {
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };

  home-manager.users.sakulk = {
    home.file.".wallpaper".source = ./wallpaper.jpg;
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        menu = "rofi -show drun";
        modifier = modifier;
        terminal = "alacritty";
        keybindings = lib.mkOptionDefault {
          "${modifier}+p" =
            "exec rofi -show power-menu -modi power-menu:rofi-power-menu";
        };
        startup = [
          {
            command = "${pkgs.i3-auto-layout}/bin/i3-auto-layout";
            notification = false;
            always = true;
          }
          {
            command = "feh --bg-scale ~/.wallpaper";
            notification = false;
            always = true;
          }
        ];
        window = {
          border = 0;
          titlebar = false;
          hideEdgeBorders = "smart";
        };
        gaps = {
          smartBorders = "on";
          smartGaps = true;
          inner = 10;
          outer = 5;
        };
        colors = {
          focused = {
            background = "#1d2021";
            border = "#504945";
            childBorder = "#504945";
            indicator = "#504945";
            text = "#ebdbb2";
          };
          focusedInactive = {
            background = "#1d2021";
            border = "#333333";
            childBorder = "#5f676a";
            indicator = "#484e50";
            text = "#ebdbb2";
          };
          unfocused = {
            background = "#1d2021";
            border = "#2f343a";
            childBorder = "#2f343a";
            indicator = "#1d2021";
            text = "#504945";
          };
        };
        bars = [{
          mode = "dock";
          hiddenState = "hide";
          position = "top";
          workspaceButtons = true;
          workspaceNumbers = true;
          statusCommand =
            "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
          fonts = {
            names = [ "JetBrainsMono Nerd Font" ];
            size = 12.0;
          };
          trayOutput = "primary";
          colors = {
            background = "#1d2021";
            statusline = "#ffffff";
            separator = "#666666";
            focusedWorkspace = {
              border = "#fabd2f";
              background = "#d79921";
              text = "#282828";
            };
            activeWorkspace = {
              border = "#504945";
              background = "#504945";
              text = "#d79921";
            };
            inactiveWorkspace = {
              border = "#504945";
              background = "#504945";
              text = "#1d2021";
            };
            urgentWorkspace = {
              border = "#2f343a";
              background = "#900000";
              text = "#ffffff";
            };
            bindingMode = {
              border = "#2f343a";
              background = "#900000";
              text = "#ffffff";
            };
          };
        }];
      };
    };

    programs.i3status-rust = {
      enable = true;
      bars = {
        default = {
          icons = "material-nf";
          theme = "gruvbox-dark";
          blocks = [
            {
              block = "disk_space";
              path = "/";
              alias = "/";
              info_type = "available";
              unit = "GB";
              interval = 60;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "memory";
              display_type = "memory";
              format_mem = "{mem_total_used_percents}%";
              format_swap = "{swap_used_percents}%";
            }
            {
              block = "cpu";
              interval = 1;
            }
            {
              block = "load";
              interval = 1;
              format = "{1m}";
            }
            { block = "sound"; }
            {
              block = "time";
              interval = 60;
              format = "%a %d/%m %R";
            }
          ];
        };
      };
    };
  };

}
