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
        terminal = "--no-startup-id alacritty";
        keybindings = lib.mkOptionDefault {
          "${modifier}+p" =
            "exec rofi -show power-menu -modi power-menu:rofi-power-menu";
          "${modifier}+r" = "exec rofi -show run";
          "${modifier}+a" = "exec rofi-audio-sink";
          "${modifier}+l" = "exec i3lock-fancy-rapid 10 3";
          "Print" = ''
            exec --no-startup-id maim "/home/$USER/Pictures/screenshot_$(date +'%Y-%m-%d_%T').png"'';
          "Shift+Print" = ''
            exec --no-startup-id maim --select "/home/$USER/Pictures/screenshot_$(date +'%Y-%m-%d_%T').png"'';
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          # "XF86MonBrightnessUp" = "exec xbacklight -inc 20";
          # "XF86MonBrightnessDown" = "exec xbacklight -dec 20";
          "XF86AudioRaiseVolume" =
            "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" =
            "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
        startup = [
          {
            command = "autorandr -c";
            notification = false;
            always = true;
          }
          {
            command = "${pkgs.i3-auto-layout}/bin/i3-auto-layout";
            notification = false;
            always = true;
          }
          {
            command = "${pkgs.feh}/bin/feh --bg-scale ~/.wallpaper";
            notification = false;
            always = true;
          }
        ];
        window = {
          border = 2;
          titlebar = false;
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
            border = "#a89984";
            childBorder = "#a89984";
            indicator = "#a89984";
            text = "#ebdbb2";
          };
          focusedInactive = {
            background = "#1d2021";
            border = "#2f343a";
            childBorder = "#2f343a";
            indicator = "#2f343a";
            text = "#a89984";
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
            size = 11.0;
          };
          trayOutput = "primary";
          extraConfig = ''
            tray_padding 5
            workspace_min_width 40
          '';
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
              background = "#9d0006";
              text = "#ebdbb2";
            };
            bindingMode = {
              border = "#2f343a";
              background = "#9d0006";
              text = "#ebdbb2";
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
          settings = {
            icons = {
              name = "material-nf";
              overrides = { bat_not_available = ""; };
            };
          };
          blocks = [
            {
              block = "music";
              player = "spotify";
              buttons = [ "play" "next" ];
              on_collapsed_click = "spotify";
            }
            {
              block = "memory";
              display_type = "memory";
              format_mem = "{mem_used;G}";
              format_swap = "{swap_used;G}";
            }
            {
              block = "cpu";
              interval = 1;
              format = "{barchart} {utilization}";
            }
            {
              block = "networkmanager";
              on_click = "alacritty -e nmtui";
              interface_name_exclude = [ "br\\-[0-9a-f]{12}" "docker\\d+" ];
              interface_name_include = [ ];
              ap_format = "{ssid^10}";
              device_format = "{icon}{ap}";
            }
            { block = "sound"; }
            {
              block = "battery";
              allow_missing = true;
              hide_missing = true;
              interval = 60;
            }
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
