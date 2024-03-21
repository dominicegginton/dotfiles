{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.sway;

  # Super key is the Windows key on most keyboards
  # and the Command key on Apple keyboards (MacBooks)
  super = "Mod4";

  # Alt key is the Alt key on most keyboards
  # and the Option key on Apple keyboards (MacBooks)
  alt = "Mod1";
in {
  options.modules.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = "1";
      XDG_CURRENT_DESKTOP = "sway";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    wayland.windowManager.sway = {
      enable = true;
      swaynag.enable = true;
      config = rec {
        modifier = super;
        fonts.names = ["JetBrainsMono Nerd Font" "FontAwesome5Free"];
        fonts.size = 11.0;
        focus.followMouse = true;
        bars = [
          {
            id = "bar-0";
            position = "top";
            mode = "hide";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bar-0.toml";
          }
        ];
        terminal = "${pkgs.alacritty}/bin/alacritty";
        keybindings = mkOptionDefault {
          "${super}+Shift+e" = "exit";
          "${super}+Shift+c" = "reload";
          "${super}+Shift+q" = "kill";
          "${super}+Shift+Escape" = "exec ${pkgs.wlogout}/bin/wlogout";
          "${super}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${super}+d" = "exec ${pkgs.kickoff}/bin/kickoff";
          "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
          "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
          "XF86AudioRaiseVolume" = "exec '${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%'";
          "XF86AudioLowerVolume" = "exec '${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%'";
          "XF86AudioMute" = "exec '${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle'";
          "XF86AudioMicMute" = "exec '${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle'";
          "${super}+p" = "exec ${pkgs.shotman}/bin/shotman --capture region --image-editor ${pkgs.gimp}/bin/gimp";
          "${super}+m" = "bar mode toggle";
          "${super}+n" = "exec '[ \"$(swaymsg -t get_bar_config bar-0 | ${pkgs.jq}/bin/jq -r \".mode\")\" = \"dock\" ] && swaymsg bar mode invisible || swaymsg bar mode dock'";
          "${super}+Control+Shift+Right" = "move workspace to output right";
          "${super}+Control+Shift+Left" = "move workspace to output left";
          "${super}+Control+Shift+Down" = "move workspace to output down";
          "${super}+Control+Shift+Up" = "move workspace to output up";
        };
        window = mkOptionDefault {
          border = 2;
          titlebar = false;
          hideEdgeBorders = "smart";
        };
        startup = [
          {command = "dbus-sway-environment";} # Set environment variables and start dbus
          {command = "configure-gtk";} # Set and configure GTK theme
          {command = "${pkgs.swaynag-battery}/bin/swaynag-battery --treshold 20";} # Start battery notification daemon
          {command = "systemctl --user start kanshi.service";} # Start display configuration daemon
          {command = "systemctl --user start mako.service";} # Start notification daemon
          {command = "blueman-applet";} # Start bluetooth applet for system tray
          {command = "${pkgs.wl-clipboard}/bin/wl-copy -t text --watch clipman store --no-persist";} # Start clipboard manager
          {command = "${pkgs.swaybg}/bin/swaybg --image ${./background.jpg} --mode 'fill' --output '*'";} # Set background image
          # {command = "${pkgs.mpvpaper}/bin/mpvpaper --fork -o 'no-audio loop script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp' -l background '*' 'https://www.youtube.com/watch?v='";}
        ];
        floating = mkOptionDefault {
          titlebar = true;
          criteria = [
            {app_id = "pcmanfm";}
            {app_id = ".blueman-manager-wrapped";}
            {app_id = "pavucontrol";}
          ];
        };
        colors = mkOptionDefault {
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
            childBorder = "#24292e";
            indicator = "#ffffff";
            text = "#666666";
          };
          urgent = {
            background = "#f95a99";
            border = "#f95a99";
            childBorder = "#f95a99";
            indicator = "#f95a99";
            text = "#24292e";
          };
          background = "#666666";
        };
      };
    };

    # I3status-rust configuration.
    # `i3status-rust` is a replacement for i3status and
    # is called by `swaybar` to display the status bar
    # information.
    programs.i3status-rust = {
      enable = true;
      bars = {
        bar-0 = {
          theme = "native";
          icons = "awesome6";
          blocks = [
            {
              block = "battery";
              format = " $percentage ";
              interval = 10;
            }
            {
              block = "sound";
            }
            {
              block = "time";
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
              interval = 10;
            }
          ];
        };
      };
    };

    # Wlogout configuration.
    programs.wlogout.enable = true;

    # Swaylock configuration.
    # `swaylock` is a screen locker for Wayland.
    # It is called by `wlogout` to lock the screen.
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        screenshots = true;
        clock = true;
        effect-blur = "7x5";
        indicator-radius = 100;
        indicator-thickness = 7;
        ring-color = "bb00cc";
        key-hl-color = "880033";
        line-color = "000000";
        inside-color = "000000";
        separator-color = "000000";
        grace = 0;
      };
    };

    services.swayosd.enable = true;
    services.avizo.enable = true;
    services.swayidle = {
      enable = true;
      timeouts = [
        # {
        #   timeout = 300;
        #   command = "${pkgs.swaylock-effects}/bin/swaylock";
        # }
      ];
    };

    # Pointer Cursor configuration.
    # Requied for hiDPI displays to have a proper cursor size.
    # The cursor size is set to 24 pixels.
    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;

      # Set for X11 and xwayland applications.
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };
  };
}
