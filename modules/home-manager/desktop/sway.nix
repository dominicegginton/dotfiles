{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.modules.desktop.sway;
  kanshiCfg = config.modules.desktop.kanshi;

  super = "Mod4";
in

with lib;

{
  options.modules.desktop = {
    sway.enable = mkEnableOption {
      default = true;
      description = "Sway window manager";
    };

    kanshi.config = mkOption {
      description = "Configuration for the Kanshi display manager";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = "1";
      XDG_CURRENT_DESKTOP = "sway";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GTK_THEME = "Colloid:${config.modules.theme}";
    };

    wayland.windowManager.sway = {
      enable = true;
      package = null;
      swaynag.enable = true;
      config = {
        modifier = super;
        fonts.names = [ "JetBrainsMono Nerd Font" "FontAwesome5Free" ];
        fonts.size = 11.0;
        focus.followMouse = true;
        bars = [
          {
            id = "bar-0";
            position = "top";
            mode = "hide";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bar-0.toml";
            colors =
              with config.scheme.withHashtag;
              let
                c = color: { text = base00; background = color; border = color; };
              in
              {
                background = blue;
                statusline = base00;
                separator = base00;
                focusedWorkspace = c base06;
                activeWorkspace = c blue;
                inactiveWorkspace = c blue;
                urgentWorkspace = c red;
                bindingMode = c yellow;
              };
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
          { command = "dbus-sway-environment"; }
          { command = "configure-gtk"; }
          { command = "systemctl --user start kanshi.service"; }
          { command = "systemctl --user start mako.service"; }
          { command = "blueman-applet"; }
          { command = "${pkgs.swaynag-battery}/bin/swaynag-battery --treshold 20"; }
          { command = "${pkgs.wl-clipboard}/bin/wl-copy -t text --watch clipman store --no-persist"; }
          { command = "${pkgs.swaybg}/bin/swaybg --image ${./background.jpg} --mode 'fill' --output '*'"; }
          # {command = "${pkgs.mpvpaper}/bin/mpvpaper --fork -o 'no-audio loop script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp' -l background '*' 'https://www.youtube.com/watch?v='";}
        ];
        floating = mkOptionDefault {
          titlebar = true;
          criteria = [
            { app_id = "pcmanfm"; }
            { app_id = ".blueman-manager-wrapped"; }
            { app_id = "pavucontrol"; }
            { app_id = "nwg-displays"; }
            { app_id = "teams-for-linux"; }
            { app_id = "whatsapp-for-linux"; }
            { app_id = "org.telegram.desktop"; }
          ];
        };
        colors =
          with config.scheme.withHashtag;
          {
            focused = {
              background = green;
              border = green;
              childBorder = blue;
              indicator = base00;
              text = base00;
            };
            focusedInactive = {
              background = base06;
              border = base06;
              childBorder = blue;
              indicator = base00;
              text = base06;
            };
            unfocused = {
              background = base06;
              border = base06;
              childBorder = base06;
              indicator = base00;
              text = base06;
            };
            urgent = {
              background = red;
              border = red;
              childBorder = red;
              indicator = base00;
              text = base06;
            };
            background = base00;
          };
      };
    };

    programs.i3status-rust = {
      enable = true;
      bars = {
        bar-0 = {
          theme = "native";
          icons = "awesome6";
          blocks = [
            {
              block = "disk_space";
              path = "/";
              info_type = "available";
              interval = 60;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "battery";
            }
            {
              block = "sound";
            }
            {
              block = "time";
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            }
          ];
        };
      };
    };

    services.swayosd.enable = true;
    services.avizo.enable = true;
    services.swayidle.enable = true;
    services.swayidle.timeouts = [ ];
    programs.wlogout.enable = true;
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        screenshots = true;
        clock = true;
        effect-blur = "7x5";
        indicator-radius = 100;
        indicator-thickness = 7;
        # TODO: apply theme colors
        ring-color = "bb00cc";
        key-hl-color = "880033";
        line-color = "000000";
        inside-color = "000000";
        separator-color = "000000";
        grace = 0;
      };
    };
    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;
      x11.enable = true;
      x11.defaultCursor = "Adwaita";
    };
    home.packages = [ pkgs.unstable.libdrm ];

    home.file.".config/kanshi/config".text = kanshiCfg.config or '''';
  };
}
