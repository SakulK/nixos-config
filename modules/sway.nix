{ pkgs, lib, ... }:

let
  modifier = "Mod4";
  colors = import ./colors;
in
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
  ];

  home-manager.users.sakulk = {
    home.file.".wallpaper".source = ./wallpaper.png;
    wayland.windowManager.sway = {
      enable = true;
      checkConfig = false;
      config = {
        menu = "rofi -show drun -show-icons";
        modifier = modifier;
        terminal = "--no-startup-id alacritty";
        output = {
          "DP-1" = {
            res = "2560x1440@144Hz";
            bg = "~/.wallpaper fill";
          };
        };
        input = {
          "type:pointer" = {
            accel_profile = "flat";
          };
          "type:keyboard" = {
            xkb_layout = "pl";
          };
        };
        keybindings = lib.mkOptionDefault {
          "${modifier}+h" = "focus left";
          "${modifier}+l" = "focus right";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+p" = "exec rofi -show power-menu -modi power-menu:rofi-power-menu";
          "${modifier}+r" = "exec rofi -show run";
          "${modifier}+a" = "exec rofi-audio-sink";
          "${modifier}+Shift+a" = "exec rofi-audio-source";
          "${modifier}+Shift+x" = "exec swaylock";
          "${modifier}+m" = "move workspace to output left";
          "Print" =
            ''exec --no-startup-id grim "/home/$USER/Pictures/screenshot_$(date +'%Y-%m-%d_%H_%M_%S').png"'';
          "Shift+Print" =
            ''exec --no-startup-id grim -g "$(slurp)" "/home/$USER/Pictures/screenshot_$(date +'%Y-%m-%d_%H_%M_%S').png"'';
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86MonBrightnessUp" = "exec light -A 30";
          "XF86MonBrightnessDown" = "exec light -U 30";
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
        window = {
          border = 2;
          titlebar = false;
          commands = [
            {
              command = "border pixel 2";
              criteria = {
                class = ".*";
              };
            }
          ];
        };
        gaps = {
          smartBorders = "on";
          smartGaps = true;
          inner = 10;
          outer = 5;
        };
        colors = {
          focused = {
            background = colors.bg0;
            border = colors.bg4;
            childBorder = colors.bg4;
            indicator = colors.bg4;
            text = colors.fg;
          };
          focusedInactive = {
            background = colors.bg0;
            border = colors.bg0_h;
            childBorder = colors.bg0_h;
            indicator = colors.bg0_h;
            text = colors.fg4;
          };
          unfocused = {
            background = colors.bg0;
            border = colors.bg0_h;
            childBorder = colors.bg0_h;
            indicator = colors.bg0_h;
            text = colors.bg2;
          };
          placeholder = {
            background = colors.bg0;
            border = colors.bg0_h;
            childBorder = colors.bg0_h;
            indicator = colors.bg0_h;
            text = colors.bg2;
          };
        };
        bars = [ ];
      };
    };

    programs.swaylock = {
      settings = {
        image = "~/.wallpaper";
      };
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
      ];
      timeouts = [
        {
          timeout = 120;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
        {
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
        {
          timeout = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [
            "sway/workspaces"
            "sway/mode"
          ];
          modules-center = [
            "sway/window"
          ];
          modules-right = [
            "disk"
            "memory"
            "cpu"
            "network"
            "pulseaudio"
            "idle_inhibitor"
            "clock"
            "tray"
          ];
          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };
          "sway/window" = {
            max-length = 100;
          };
          "disk" = {
            format = "󰋊 {free}";
            states = {
              warning = 90;
              critical = 95;
            };
          };
          "memory" = {
            format = "  {used}GiB";
            states = {
              warning = 60;
              critical = 80;
            };
          };
          "cpu" = {
            interval = 2;
            format = "  {icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}{icon8}{icon9}{icon10}{icon11}{icon12}{icon13}{icon14}{icon15} {usage}%";
            "format-icons" = [
              "▁"
              "▂"
              "▃"
              "▄"
              "▅"
              "▆"
              "▇"
              "█"
            ];
            states = {
              warning = 50;
              critical = 80;
            };
          };
          "network" = {
            format-ethernet = "󰈀";
            format-wifi = " {frequency} {essid}";
            format-disabled = ''<span style="background-color: ${colors.yellow}">󰖪</span>'';
            format-disconnected = ''<span style="background-color: ${colors.red}">󰖪</span>'';
            tooltip-format = "{ifname} {ipaddr}";
            on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.networkmanager}/bin/nmtui";
          };
          "pulseaudio" = {
            format = " {volume}%";
            format-muted = " ";
            on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          };
          "clock" = {
            format = "{:%a %Y-%m-%d %H:%M}";
          };
          "idle_inhibitor" = {
            format = "{icon} ";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };
          "tray" = {
            spacing = 6;
          };
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: JetBrainsMono Nerd Font;
          font-size: 14px;
          min-height: 0;
        }
        window#waybar {
          background: ${colors.bg0};
          color: ${colors.fg};
        }
        #workspaces button {
          padding: 0 5px;
          background-color: ${colors.bg2};
          color: ${colors.bg0};
        }
        #workspaces button.focused {
          background-color: ${colors.yellow};
          color: ${colors.bg0};
        }
        #workspaces button.urgent {
          background-color: ${colors.dark_red};
        }
        #pulseaudio, #network, #disk, #cpu, #memory, #backlight, #battery, #clock, #idle_inhibitor, #tray {
          padding: 0 6px;
          margin: 0 6px;
        }
        #pulseaudio.muted {
          background-color: ${colors.yellow};
          color: ${colors.bg0};
        }
        #clock {
          background-color: ${colors.bg2};
        }
        .warning {
          color: ${colors.yellow};
        }
        .critical {
          color: ${colors.red};
        }
        #idle_inhibitor.activated {
          background-color: ${colors.yellow};
          color: ${colors.bg0};
        }
      '';
    };
  };
}
