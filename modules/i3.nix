{ pkgs, lib, ... }:

let modifier = "Mod4";
in {
  services.xserver.windowManager.i3 = { enable = true; };

  home-manager.users.sakulk = {
    home.file.".wallpaper".source = ./wallpaper.png;
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        menu = "rofi -show drun";
        modifier = modifier;
        terminal = "--no-startup-id alacritty";
        keybindings = lib.mkOptionDefault {
          "${modifier}+h" = "focus left";
          "${modifier}+l" = "focus right";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+p" =
            "exec rofi -show power-menu -modi power-menu:rofi-power-menu";
          "${modifier}+r" = "exec rofi -show run";
          "${modifier}+a" = "exec rofi-audio-sink";
          "${modifier}+Shift+a" = "exec rofi-audio-source";
          "${modifier}+Shift+x" = "exec i3lock-fancy-rapid 10 3";
          "${modifier}+m" = "move workspace to output left";
          "Print" = ''
            exec --no-startup-id maim "/home/$USER/Pictures/screenshot_$(date +'%Y-%m-%d_%H_%M_%S').png"'';
          "Shift+Print" = ''
            exec --no-startup-id maim --select "/home/$USER/Pictures/screenshot_$(date +'%Y-%m-%d_%H_%M_%S').png"'';
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86MonBrightnessUp" = "exec light -A 30";
          "XF86MonBrightnessDown" = "exec light -U 30";
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
            command = "${pkgs.feh}/bin/feh --bg-scale ~/.wallpaper";
            notification = false;
            always = true;
          }
        ];
        window = {
          border = 2;
          titlebar = false;
          commands = [{
            command = "border pixel 2";
            criteria = { class = ".*"; };
          }];
        };
        gaps = {
          smartBorders = "on";
          smartGaps = true;
          inner = 10;
          outer = 5;
        };
        colors = {
          focused = {
            background = "#282828";
            border = "#7c6f64";
            childBorder = "#7c6f64";
            indicator = "#7c6f64";
            text = "#ebdbb2";
          };
          focusedInactive = {
            background = "#282828";
            border = "#1d2021";
            childBorder = "#1d2021";
            indicator = "#1d2021";
            text = "#a89984";
          };
          unfocused = {
            background = "#282828";
            border = "#1d2021";
            childBorder = "#1d2021";
            indicator = "#1d2021";
            text = "#504945";
          };
          placeholder = {
            background = "#282828";
            border = "#1d2021";
            childBorder = "#1d2021";
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
            background = "#282828";
            statusline = "#ebdbb2";
            separator = "#504945";
            focusedWorkspace = {
              border = "#d79921";
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
              text = "#282828";
            };
            urgentWorkspace = {
              border = "#9d0006";
              background = "#9d0006";
              text = "#ebdbb2";
            };
            bindingMode = {
              border = "#9d0006";
              background = "#9d0006";
              text = "#ebdbb2";
            };
          };
        }];
      };
    };

    programs.i3status-rust = {
      enable = true;
      package = pkgs.i3status-rust;
      bars = {
        default = {
          icons = "material-nf";
          theme = "gruvbox-dark";
          blocks = [
            {
              block = "music";
              format = " $icon {$title.str(max_w:20,rot_interval:0.5) $play $next |}";
              player = "spotify";
            }
            {
              block = "disk_space";
              format = " $icon $available";
            }
            {
              block = "memory";
              format = " $icon $mem_used.eng(p:Mi) ";
              format_alt = " $icon_swap $swap_used.eng(p:Mi) ";
            }
            {
              block = "cpu";
              interval = 1;
              format = " $icon $barchart $utilization";
            }
            {
              block = "net";
	      device = "^tun.*";
              format = " $icon VPN ";
	      missing_format = "";
            }
            {
              block = "net";
              format = " $icon {$ssid $frequency|} ";
              click = [{
                button = "left";
                cmd = "alacritty -e nmtui";
              }];
            }
            { block = "sound"; }
            {
              block = "battery";
              missing_format = "";
              interval = 60;
            }
            {
              block = "time";
              interval = 60;
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            }
          ];
        };
      };
    };
  };

}
