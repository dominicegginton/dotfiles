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
          "JetBrainsMono Nerd Font"
          "FontAwesome5Free"
        ];
        size = 11.0;
      };
      menu = "bemenu-run -nb -l 10 -H 22 -W 0.4 --fn 'Ubuntu' --tb '#000000' --tf '#ffffff' --fb '#000000' --ff '#ffffff' --nb '#000000' --nf '#ffffff' --hb '#000000' --hf '#ffffff'";
      bars = [{command = "waybar";}];
      colors = {
        focused = {
          background = "#58f785";
          border = "#58f785";
          childBorder = "#0366d6";
          indicator = "#58f785";
          text = "#ffffff";
        };
        focusedInactive = {
          background = "#24292e";
          border = "#24292e";
          childBorder = "#0366d6";
          indicator = "#ffffff";
          text = "#666666";
        };
        unfocused = {
          background = "#24292e";
          border = "#24292e";
          childBorder = "#0366d6";
          indicator = "#ffffff";
          text = "#666666";
        };
        urgent = {
          background = "#f95a99";
          border = "#f95a99";
          childBorder = "#0366d6";
          indicator = "#f95a99";
          text = "#24292e";
        };
        background = "#666666";
      };
    };
    extraConfig = ''
      exec dbus-sway-environment
      exec configure-gtk
      exec sleep 5; systemctl --user start kanshi.service
      output * bg ~/background.jpg fill
      exec swayosd-server
      bindsym Mod4+c exec grim  -g "$(slurp)" /tmp/$(date +'%H:%M:%S.png')
      bindsym XF86MonBrightnessDown exec light -U 10 exec swayosd --brightness lower
      bindsym XF86MonBrightnessUp exec light -A 10 exec swayosd --brightness raise
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +5%' exec swayosd --output-volume raise
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -5%' exec swayosd --output-volume lower
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle' exec swayosd --output-volume mute-toggle
      bindsym XF86AudioMicMute exec 'pactl set-source-mute @DEFAULT_SOURCE@ toggle' exec swayosd --input-volume mute-toggle
      bindsym --release Caps_Lock exec swayosd --caps-lock
      default_border pixel 2
      default_floating_border normal
      titlebar_border_thickness 0
      hide_edge_borders both
      smart_borders on
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
        layer = "bottom";
        position = "top";
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/scratchpad"
          "idle_inhibitor"
        ];
        modules-center = [];
        modules-right = [
          "cpu"
          "memory"
          "network"
          "pulseaudio"
          "backlight"
          "clock"
          "battery"
          "temperature"
          "tray"
        ];
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name} {icon}";
          format-icons = {
            "0" = "";
            "1" = "";
            "2" = "";
            "3" = "";
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
        tray = {
          "icon-size" = 21;
          spacing = 10;
        };
        memory = {
          interval = 5;
          format = " {}%";
        };
        cpu = {
          interval = 1;
          format = "🖳 {usage:2}%";
        };
        clock = {
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          "format-alt" = "{:%d-%m-%y}";
        };
        backlight = {
          "format" = "{percent}% {icon}";
          "format-icons" = ["" "" "" "" "" "" "" "" ""];
        };
        pulseaudio = {
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
		      format = "{icon}  {capacity}%";
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
        temperature = {
          "critical-threshold" = 75;
          "format-critical" = "{temperatureC}°C ";
          format = "{temperatureC}°C ";
          tooltip = true;
        };
        "idle_inhibitor" = {
          format = "{icon}";
          "format-icons" = {
            activated = "";
            deactivated = "";
          };
        };
      };
    };
    style = ''
      * {
        color: #24292e;
        border: 0;
        border-radius: 0;
        padding: 0 0;
        font-family: JetBrainsMono Nerd Font;
        font-size: 15px;
        margin-right: 5px;
        margin-left: 5px;
        padding-bottom:3px;
      }
      window#waybar {
        background: #ffffff;
      }
      #workspaces button {
        padding: 2px 0px;
        border-bottom: 2px;
        color: #eceff4;
        border-color: #d8dee9;
        border-style: solid;
        margin-top:2px;
      }
      #workspaces button.focused {
        border-color: #a3be8c;
      }
      #workspaces button.visible {
        border-color: #81a1c1;
      }
      #workspaces button.urgent {
        border-color: #b48ead;
      }
      #mode {
        color: #ebcb8b;
      }
      #clock, #cpu, #memory,#idle_inhibitor, #temperature,#custom-keyboard-layout, #backlight, #network, #pulseaudio, #mode, #tray, #window,#custom-launcher,#custom-power,#custom-pacman {
        padding: 0 3px;
        border-bottom: 2px;
        border-style: solid;
      }
      #clock {
        color:#a3be8c;
      }
      #backlight {
        color: #ebcb8b;
      }
      #battery {
        color: #384e59;
      }
      #battery.charging {
        color: #81a1c1;
      }
      @keyframes blink {
        to {
          color: #4c566a;
          background-color: #eceff4;
        }
      }
      #battery.critical:not(.charging) {
        background: #bf616a;
        color: #eceff4;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      #cpu {
        color:#a3be8c ;
      }
      #memory {
        color: #d3869b;
      }
      #network.disabled {
        color:#bf616a;
      }
      #network{
        color:#a3be8c;
      }
      #network.disconnected {
        color: #bf616a;
      }
      #pulseaudio {
        color: #b48ead;
      }
      #pulseaudio.muted {
        color: #3b4252;
      }
      #temperature {
        color: #8fbcbb;
      }
      #temperature.critical {
        color: #bf616a;
      }
      #idle_inhibitor {
        color: #ebcb8b;
      }
      #tray {}
      #custom-launcher,#custom-power{
        border-style: hidden;
        margin-top:2px;
      }
      #window{
        border-style: hidden;
        margin-top:1px;
      }
      #mode{
        margin-bottom:3px;
      }
      #custom-keyboard-layout{
        color:#d08770;
      }
      tooltip {
        color: black;
        background-color: white;
        text-shadow: none;
        border-style: solid;
        border-color: black;
        border-width: 2px;
      }
      tooltip * {
        color: black;
        text-shadow: none;
      }
    '';
  };
}
