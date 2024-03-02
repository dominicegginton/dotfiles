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
      terminal = "${pkgs.alacritty}/bin/alacritty";
      fonts = {
        names = ["JetBrainsMono Nerd Font" "FontAwesome5Free"];
        size = 11.0;
      };
      bars = [];
      menu = "${pkgs.alacritty}/bin/alacritty --class=launcher -e ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
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
      # background
      output * bg ~/background.jpg fill

      # screenshots
      bindsym Mod4+c exec flameshot gui

      # brightness
      bindsym XF86MonBrightnessDown exec light -U 10
      bindsym XF86MonBrightnessUp exec light -A 10

      # wlogout
      bindsym Mod4+Shift+Escape exec wlogout

      # volume
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +5%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -5%'
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'
      bindsym XF86AudioMicMute exec 'pactl set-source-mute @DEFAULT_SOURCE@ toggle'

      # move workspace
      bindsym Mod4+Control+Shift+Right move workspace to output right;
      bindsym Mod4+Control+Shift+Left move workspace to output left
      bindsym Mod4+Control+Shift+Down move workspace to output down
      bindsym Mod4+Control+Shift+Up move workspace to output up

      # swayosd
      bindsym --release Caps_Lock exec swayosd --caps-lock

      # touchpad gestures
      bindgesture swipe:right workspace prev
      bindgesture swipe:left workspace next

      # borders
      default_border pixel 2
      default_floating_border normal
      titlebar_border_thickness 0
      hide_edge_borders both
      smart_borders on

      # window configuration
      for_window [app_id="^launcher$"] floating enable
      for_window [app_id="^firefox$"] move window to workspace 2, focus
      for_window [app_id="^teams-for-linux$"] move window to workspace 9, focus
      for_window [app_id="^thunderbird$"] move window to workspace 9, focus
      for_window [app_id="^pavucontrol$"] floating enable, resize set 800 600, move position center

      # exec
      exec dbus-sway-environmen
      exec configure-gtk
      exec swayosd-server
      exec eww d
      exec sleep 5; systemctl --user start kanshi.service
    '';
  };

  # cursor configuration for hiDPI displays
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };
}
