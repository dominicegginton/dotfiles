{
  config,
  lib,
  pkgs,
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

  config = {
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
          "${super}+Shift+Escape" = "exec wlogout";
          "${super}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${super}+d" = "exec ${pkgs.kickoff}/bin/kickoff";
          "XF86MonBrightnessDown" = "exec light -U 10";
          "XF86MonBrightnessUp" = "exec light -A 10";
          "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +5%'";
          "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -5%'";
          "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
          "XF86AudioMicMute" = "exec 'pactl set-source-mute @DEFAULT_SOURCE@ toggle'";
          "Print" = "exec ${pkgs.flameshot}/bin/flameshot gui";
          "${super}+m" = "bar mode toggle";
          "${super}+n" = "exec '[ \"$(swaymsg -t get_bar_config bar-0 | ${pkgs.jq}/bin/jq -r \".mode\")\" = \"dock\" ] && swaymsg bar mode invisible || swaymsg bar mode dock'";
          "${super}+Control+Shift+Right" = "move workspace to output right";
          "${super}+Control+Shift+Left" = "move workspace to output left";
          "${super}+Control+Shift+Down" = "move workspace to output down";
          "${super}+Control+Shift+Up" = "move workspace to output up";
        };
        window = {
          border = 2;
          titlebar = false;
          hideEdgeBorders = "smart";
        };
        startup = [
          {command = "dbus-sway-environment";}
          {command = "configure-gtk";}
          {command = "${pkgs.mako}/bin/mako";}
          {command = "${pkgs.swaynag-battery}/bin/swaynag-battery --treshold 20";}
          {command = "systemctl --user start kanshi.service";}
          {command = "systemctl --user start mako.service";}
          {command = "blueman-applet";}
          {command = "${pkgs.swaybg}/bin/swaybg --image ${./background.jpg} --mode 'fill' --output '*'";}
          # {command = "${pkgs.mpvpaper}/bin/mpvpaper --fork -o 'no-audio loop script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp' -l background '*' 'https://www.youtube.com/watch?v='";}
        ];
        floating = {
          titlebar = true;
          criteria = [
            {class = "Pavucontrol";}
            {class = "Blueman-manager";}
          ];
        };
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
      extraConfig = ''
        # output * bg ~/background.jpg fill
      '';
    };

    # I3status-rust configuration.
    # `i3status-rust` is a replacement for i3status and
    # is called by `swaybar` to display the status bar
    # information.
    programs.i3status-rust = {
      enable = true;
      bars = {
        bar-0 = {
          blocks = [
            {
              block = "sound";
            }
            {
              block = "time";
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
              interval = 60;
            }
          ];
        };
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = "808080";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        line-color = "ffffff";
        show-failed-attempts = true;
      };
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
