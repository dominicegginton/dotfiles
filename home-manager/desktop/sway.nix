{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_USE_XINPUT2 = "1";
    XDG_CURRENT_DESKTOP = "sway";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      fonts = {
        names = [
          "Noto Sans Mono"
          "FontAwesome5Free"
        ];
        style = "Bold Semi-Condensed";
        size = 11.0;
      };
      menu = "bemenu-run -nb -l 10 -H 22 -W 0.4 --fn 'Ubuntu' --tb '#000000' --tf '#ffffff' --fb '#000000' --ff '#ffffff' --nb '#000000' --nf '#ffffff' --hb '#000000' --hf '#ffffff'";
      bars = [{command = "waybar";}];
      colors = {
        focused = {
          background = "#0366D6";
          border = "#0366D6";
          childBorder = "#0366D6";
          indicator = "#0366D6";
          text = "#FFFFFF";
        };
        focusedInactive = {
          background = "#3192AA";
          border = "#3192AA";
          childBorder = "#3192AA";
          indicator = "#3192AA";
          text = "#FFFFFF";
        };
        unfocused = {
          background = "#000000";
          border = "#000000";
          childBorder = "#000000";
          indicator = "#000000";
          text = "#FFFFFF";
        };
        urgent = {
          background = "#DBAB09";
          border = "#DBAB09";
          childBorder = "#DBAB09";
          indicator = "#DBAB09";
          text = "#FFFFFF";
        };
        placeholder = {
          background = "#000000";
          border = "#000000";
          childBorder = "#000000";
          indicator = "#000000";
          text = "#FFFFFF";
        };
        background = "#000000";
      };
    };
    extraConfig = ''
      exec dbus-sway-environment
      exec configure-gtk
      exec sleep 5; systemctl --user start kanshi.service
      output * bg ~/background.jpg fill
      bindsym Mod4+c exec grim  -g "$(slurp)" /tmp/$(date +'%H:%M:%S.png')
      bindsym XF86MonBrightnessDown exec light -U 10
      bindsym XF86MonBrightnessUp exec light -A 10
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +5%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -5%'
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'
    '';
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 25;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/scratchpad"
          "sway/window"
        ];
        modules-center = [];
        modules-right = [
          "pulseaudio"
          "network"
          "backlight"
          "clock"
          "tray"
          "battery"
        ];
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name} {icon}";
          "format-icons" = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            urgent = "";
            focused = "";
            default = "";
          };
        };
        "sway/mode" = {
          "format" = "{mode}";
          "format-icons" = {
            default = "";
            resize = "";
            move = "";
          };
        };
        "sway/scratchpad" = {
          "format" = "{count}";
          "format-icons" = {
            default = "";
          };
        };
        "sway/window" = {
          "format" = "{title}";
          "format-icons" = {
            default = "";
          };
        };
        "tray" = {
          "icon-size" = 21;
          "spacing" = 10;
        };
        "clock" = {
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          "format-alt" = "{:%d-%m-%y}";
        };
        "backlight" = {
          "format" = "{percent}% {icon}";
          "format-icons" = ["" "" "" "" "" "" "" "" ""];
        };
        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
        };
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          "format-charging" = "{capacity}% ";
          "format-plugged" = "{capacity}% ";
          "format-alt" = "{time} {icon}";
          "format-icons" = ["" "" "" "" ""];
        };
        network = {
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr}/{cidr} ";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "Disconnected ⚠";
          "format-alt" = "{ifname}= {ipaddr}/{cidr}";
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0px;
        font-family: Ubuntu Nerd Font;
        font-size: 16px;
        font-weight: bold;
        min-height: 25px;
      }
      window#waybar {
        background-color: rgba(242, 242, 242, 1.0);
        border-bottom: 0px solid rgba(100, 114, 125, 0.5);
        color: #595959;
        transition-property: background-color;
        transition-duration: .5s;
        border-radius: 0px;
      }

      window#waybar.hidden {
        opacity: 0;
      }

      window#waybar.empty #window {
        background: none;
      }

      #workspaces button {
        padding: 2px 10px;
        margin-right: 5px;
        background-color: transparent;
        color: #595959;
        box-shadow: inset 0px -0px transparent;
        border-radius: 0px;
      }
      #workspaces button:hover {
        padding: 2px 10px;
        margin-right: 5px;
        background: rgba(196, 196, 196, 0.7);
        color: #000000;
        box-shadow: inset 0px -0px #ffffff;
        outline-style: none;
        text-shadow: none;
      }
      #workspaces button.focused {
        padding: 2px 10px;
        margin-right: 5px;
        background-color: #c4c4c4;
        color: #000000;
        box-shadow: inset 0px -0px #000000;
        outline-style: none;
        text-shadow: none;
      }
      #workspaces button.urgent {
        padding: 2px 10px;
        margin-right: 5px;
        background-color: #ff8f88;
        color: #ffffff;
        outline-style: none;
        text-shadow: none;
      }
      #battery,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #custom-date,
      #custom-usbdrive,
      #custom-power,
      #custom-emacsd,
      #scratchpad,
      #window,
      #mpd,
      #idle_inhibitor {
        padding: 2px 10px;
        margin: 0px 5px;
        color: #000000;
        border-radius: 5px
      }
      #mode {
        background-color: #ff8f88;
        color: #ffffff;
      }
      #scratchpad {
        background-color: #c4c4c4;
        border-radius: 0px;
        color: #000000;
      }
      #scratchpad.empty {
        background-color: transparent;
        border-radius: 0px;
        color: #595959;
      }
      #window {
        border-radius: 0px;
        background-color: #c4c4c4;
        font-family: Ubuntu;
        font-size: 16px;
        font-weight: normal;
      }
      .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
      }
      .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
      }
      #battery {
        color: #000000;
      }
      #battery.charging {
        background-color: #ffffff;
        color: #000000;
      }
      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #eee8d5;
        }
      }
      #battery.critical:not(.charging) {
        background-color: #ff8f88;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      label:focus {
        background-color: #595959;
      }
      #cpu {
        color: #000000;
      }
      #memory {
        color: #000000;
      }
      #backlight {
        color: #000000;
      }
      #network {
        color: #000000;
      }
      #network.disconnected {
        color: #ffffff;
        background-color: #ff8f88;
      }
      #pulseaudio {
        color: #000000;
      #pulseaudio.muted {
        color: #5e5C64;
      }
      #temperature {
        color: #000000;
      }
      #temperature.critical {
        color: #ffffff;
        background-color: #ff8f88;
      }
      #tray {
        background-color: #000000;
      }
      #idle_inhibitor {
        color: #595959;
      }
      #idle_inhibitor.activated {
        color: #000000;
        margin: 0px 5px;
        box-shadow: inset 0px 0px #ecF0F1;
      }
      #mpd {
        color: #000000;
      }
      #mpd.stopped {
        color: #595959;
      }
    '';
  };
}
