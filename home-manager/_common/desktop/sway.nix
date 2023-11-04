{
  config,
  pkgs,
  ...
}: let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in {
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_USE_XINPUT2 = "1";
    XDG_CURRENT_DESKTOP = "sway";
  };

  home.packages = with pkgs; [
    dbus-sway-environment
    configure-gtk
    alacritty
    wayland
    xdg-utils
    glib
    dracula-theme
    gnome3.adwaita-icon-theme
    swaylock
    swayidle
    grim # screenshot functionality
    wl-clipboard
    bemenu
    mako
    wdisplays
    pulseaudioFull
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
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
      menu = "bemenu-run -n";
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
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export MOZ_ENABLE_WAYLAND=1
    '';
    extraConfig = ''
      output * bg ~/background.jpg fill
      bindsym XF86MonBrightnessDown exec light -U 10
      bindsym XF86MonBrightnessUp exec light -A 10
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'
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
        ];
        modules-center = [];
        modules-right = [
          "mpd"
          "pulseaudio"
          "network"
          "backlight"
          "battery"
          "clock"
          "tray"
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
        mpd = {
          format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
          "format-disconnected" = "Disconnected ";
          "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
          "unknown-tag" = "N/A";
          interval = 2;
          "consume-icons" = {
            on = " ";
          };
          "random-icons" = {
            off = "<span color=\"#f53c3c\"></span> ";
            on = " ";
          };
          "repeat-icons" = {
            on = " ";
          };
          "single-icons" = {
            on = "1 ";
          };
          "state-icons" = {
            paused = "";
            playing = "";
          };
          "tooltip-format" = "MPD (connected)";
          "tooltip-format-disconnected" = "MPD (disconnected)";
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
          "on-click" = "pavucontrol";
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
         border-radius: 0;
         font-size: 14px;
         min-height: 0;
         color: #FFFFFF;
         background: #000000;
       }

       window#waybar {
         background: #000000;
       }

       #workspaces button {
         padding: 0 15px 0 0;
       }

       #workspaces button.focused {
         color: #FFFFFF;
         background: #0366D6;
       }

       #workspaces button.urgent {
         color: #000000;
         background-color: #DBAB09;
       }

       #mode {
         background: #000000;
         border-bottom: none;
       }

       #clock,
       #battery,
       #backlight,
       #network,
       #pulseaudio,
       #tray,
       #mode,
       #idle_inhibitor {
         padding: 0 10px;
         margin: 0 0px;
       }

      #battery.charging {
         background-color: #000000;
       }

       @keyframes blink {
         to {
           color: #FFFFFF;
         }
       }

       #battery.critical:not(.charging) {
         background: #f53c3c;
         animation-name: blink;
         animation-duration: 0.5s;
         animation-timing-function: linear;
         animation-iteration-count: infinite;
         animation-direction: alternate;
       }

       #idle_inhibitor.activated {
         background-color: #FFFFFF;
         color: #000000;
       }
    '';
  };
}
