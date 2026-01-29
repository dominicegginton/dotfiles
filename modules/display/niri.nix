{
  config,
  lib,
  pkgs,
  ...
}:

with config.scheme.withHashtag;

{
  options.display.niri.enable = lib.mkEnableOption "Niri";

  config = lib.mkIf config.display.niri.enable {
    hardware.graphics.enable = true;
    security = {
      polkit.enable = true;
      pam.services.swaylock = { };
    };
    xdg = {
      autostart.enable = true;
      menus.enable = true;
      icons.enable = true;
      portal = {
        wlr.enable = true;
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        configPackages = [ pkgs.niri ];
      };
    };
    services = {
      graphical-desktop.enable = true;
      printing.enable = true;
      pipewire.enable = true;
      gnome.gnome-keyring.enable = true;
      displayManager.sessionPackages = [ pkgs.niri ];
      geoclue2.enableDemoAgent = lib.mkDefault true;
    };
    programs = {
      niri.enable = true;
      dconf.enable = true;
      alacritty.enable = true;
      firefox.enable = true;
      xwayland.enable = lib.mkDefault true;
      sherlock-launcher.enable = true;
    };
    # fonts = {
    #   enableDefaultPackages = false;
    #   fontDir.enable = true;
    #   fontconfig = {
    #     enable = true;
    #     antialias = true;
    #     defaultFonts.serif = [ "Ibm Plex Serif" ];
    #     defaultFonts.sansSerif = [ "Ibm Plex Sans" ];
    #     defaultFonts.monospace = [
    #       "Ibm Plex Mono"
    #       "Noto Nerd Font Mono"
    #     ];
    #     defaultFonts.emoji = [ "Noto Color Emoji" ];
    #     hinting.autohint = true;
    #     hinting.enable = true;
    #     hinting.style = "full";
    #     subpixel.rgba = "rgb";
    #     subpixel.lcdfilter = "light";
    #   };
    #   packages = with pkgs; [
    #     font-manager
    #     nerd-fonts
    #     noto-fonts-color-emoji
    #     ibm-plex
    #   ];
    # };

    environment = {
      variables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        DISPLAY = ":0";
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_DBUS_REMOTE = "1";
        MOZ_USE_XINPUT2 = "1";
        MOZ_USE_XINPUT2_BY_DEFAULT = "1";
      };
      systemPackages = with pkgs; [
        niri
        wlsunset

        mission-center
        wdisplays
        swaysettings

        ## replace with base gnome apps
        nautilus
        sushi
        clapper
        loupe
        evince
        gnome-font-viewer
        gnome-calendar
        gnome-logs
        gnome-contacts
      ];
      etc."niri/config.kdl".text = ''
        prefer-no-csd
        spawn-at-startup "${lib.getExe pkgs.swaybg}" "--image" "${pkgs.background.backgroundImage}" "--mode" "fill"
        spawn-at-startup "${pkgs.swaysettings}/bin/sway-autostart"
        spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${lib.getExe pkgs.cliphist}" "store"
        spawn-at-startup "${lib.getExe pkgs.wlsunset}" "-S" "08:00" "-s" "19:00"
        spawn-at-startup "${lib.getExe pkgs.xwayland-satellite}"
        ${lib.optionalString config.hardware.bluetooth.enable ''spawn-at-startup "${pkgs.tlp}/bin/bluetooth" "on"''}
        ${lib.optionalString config.hardware.bluetooth.enable ''spawn-at-startup "${pkgs.blueman}/bin/blueman-applet"''}
        ${lib.optionalString config.services.printing.enable ''spawn-at-startup "${pkgs.cups}/bin/cupsd" "-l"''}
        ${lib.optionalString config.services.printing.enable ''spawn-at-startup "${pkgs.cups}/bin/cupsenable"''}
        hotkey-overlay {
          skip-at-startup
          hide-not-bound
        }
        input {
          mod-key "Super"
          mod-key-nested "Alt"
          warp-mouse-to-focus
          workspace-auto-back-and-forth
          mouse {
            accel-profile "flat"
          }
          touchpad {
            tap
            natural-scroll
            accel-profile "flat"
          }
          trackpoint {
            natural-scroll
            accel-profile "flat"
          }
        }
        output "eDP-1" {
          scale 1.0
        }
        switch-events {
          lid-close { spawn "notify-send" "The laptop lid is closed!"; }
          lid-open { spawn "notify-send" "The laptop lid is open!"; }
          tablet-mode-on { spawn "bash" "-c" "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true"; }
          tablet-mode-off { spawn "bash" "-c" "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false"; }
        }
        layout {
          gaps 0
          center-focused-column "never"
          struts {
            left 0
            right 0
            top 0
            bottom 0
          }
          focus-ring {
            width 2
            active-color "${magenta}"
            inactive-color "${base07}"
            urgent-color "${yellow}"
          }
          border {
            width 0
            active-color "${magenta}"
            inactive-color "${base07}"
            urgent-color "${yellow}"
          }
          tab-indicator {
            width 2
            active-color "${blue}"
            inactive-color "${base07}"
            urgent-color "${yellow}"
          }
          default-column-width {
            proportion 0.75
          }
          preset-column-widths {
            proportion 0.25
            proportion 0.5
            proportion 0.75
          }
        }
        overview {
          zoom 1.0
          backdrop-color "${base07}"
        }
        layer-rule {
          match namespace="^notifications$"
          block-out-from "screencast"
        }
        window-rule {
          match
          draw-border-with-background false
          geometry-corner-radius 0 0 0 0
          clip-to-geometry true
        }
        window-rule {
          match is-window-cast-target=true
          focus-ring {
            active-color "${red}"
            inactive-color "${red}"
          }
          border {
            active-color "${red}"
            inactive-color "${red}"
          }
          tab-indicator {
            active-color "${red}"
            inactive-color "${red}"
          }
        }
        window-rule {
          match is-floating=true
          geometry-corner-radius 4 4 4 4
          shadow {
            on
            softness 40
            spread 5
            offset x=0 y=5
            draw-behind-window true
            color "${base07}40"
          }
        }
        window-rule {
          match app-id="karren"
          open-floating true
          open-focused true
          min-width 880
          max-width 880
          default-column-width { proportion 0.5; }
          default-window-height { proportion 0.3; }
        }
        window-rule {
          match app-id="^org.gnome.Nautilus$"
          match app-id="^org.gnome.FileRoller$"
          match app-id="^org.gnome.Evince$"
          match app-id="^org.gnome.Calendar$"
          match app-id="^org.gnome.FontViewer$"
          match app-id="^org.gnome.Sushi$"
          match app-id="^org.gnome.Clocks$"
          match app-id="^org.gnome.Logs$"
          match app-id="^org.gnome.Todo$"
          match app-id="^org.gnome.Maps$"
          match app-id="^org.gnome.Contacts$"
          match app-id="^org.gnome.Photos$"
          match app-id="^org.gnome.Cheese$"
          match app-id="^org.gnome.Music$"
          match app-id="^org.gnome.Videos$"
          match app-id="^net.nokyan.Resources$"
          match app-id="^org.erikreider.swaysettings$"
          match app-id="^dconf-editor$"
          match app-id="^wdisplays$"
          match app-id="^com.jaoushingan.WaydroidHelper$"
          match app-id="^.blueman-manager-wrapped$"
          open-floating true
          open-focused true
          default-column-width { proportion 0.4; }
          default-window-height { proportion 0.4; }
        }
        window-rule {
          match app-id="^waydroid.com.*$"
          open-floating true
          tiled-state false
        }
        binds {
          Mod+Shift+Slash                                                { show-hotkey-overlay; }
          Mod+O                repeat=false                              { toggle-overview; }
          Mod+Shift+Q                                                    { close-window; }
          Mod+Return           hotkey-overlay-title="Alacritty"          { spawn "${lib.getExe pkgs.alacritty}"; }
          Mod+Space            hotkey-overlay-title="Launcher"           { spawn "${lib.getExe pkgs.sherlock-launcher}" "--config-dir" "/etc/sherlock-launcher/"; }
          Mod+Shift+Escape     hotkey-overlay-title="System Manager"     { spawn "${lib.getExe pkgs.karren.system-manager}"; }
          Mod+Shift+L          hotkey-overlay-title="Lock the Screen"    { spawn "${lib.getExe pkgs.swaylock-effects}" "-S" "--effect-blur" "10x10"; }
          Mod+Shift+3          hotkey-overlay-title="Screenshot: Output" { spawn "${lib.getExe (
            pkgs.writeShellScriptBin "screenshot-output" "PATH=${
              lib.makeBinPath [
                pkgs.uutils-coreutils-noprefix
                pkgs.wl-clipboard
              ]
            } ${lib.getExe pkgs.grim} -o $(${lib.getExe pkgs.niri} msg focused-output | grep Output | awk -F '[()]' '{print $2}') - | ${lib.getExe pkgs.swappy} -f -"
          )}"; }
          Mod+Shift+4          hotkey-overlay-title="Screenshot: Region" { spawn "${lib.getExe (pkgs.writeShellScriptBin "screenshot-region" ''PATH=${lib.makeBinPath [ pkgs.wl-clipboard ]} ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.swappy} -f -'')}"; }
          Mod+Shift+E                                                    { quit; }
          Mod+Shift+P                                                    { power-off-monitors; }
          Mod+Shift+H          hotkey-overlay-title="Karren: Clip Hist"  { spawn "${lib.getExe pkgs.karren.clipboard-history}"; }
          Ctrl+Alt+Delete      hotkey-overlay-title="System Monitor"     { spawn "${lib.getExe pkgs.resources}"; }
          XF86AudioPlay        allow-when-locked=true                    { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
          XF86AudioStop        allow-when-locked=true                    { spawn "${pkgs.playerctl}/bin/playerctl" "stop"; }
          XF86AudioNext        allow-when-locked=true                    { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
          XF86AudioPrev        allow-when-locked=true                    { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }
          XF86AudioRaiseVolume allow-when-locked=true                    { spawn "${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%"; }
          XF86AudioLowerVolume allow-when-locked=true                    { spawn "${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%"; }
          XF86AudioMute        allow-when-locked=true                    { spawn "${pkgs.pulseaudio}/bin/pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle"; }
          Mod+Left                                                       { focus-column-left; }
          Mod+Down                                                       { focus-window-down; }
          Mod+Up                                                         { focus-window-up; }
          Mod+Right                                                      { focus-column-right; }
          Mod+H                                                          { focus-column-left; }
          Mod+J                                                          { focus-window-down; }
          Mod+K                                                          { focus-window-up; }
          Mod+L                                                          { focus-column-right; }
          Mod+Ctrl+Left                                                  { move-column-left; }
          Mod+Ctrl+Down                                                  { move-window-down; }
          Mod+Ctrl+Up                                                    { move-window-up; }
          Mod+Ctrl+Right                                                 { move-column-right; }
          Mod+Ctrl+H                                                     { move-column-left; }
          Mod+Ctrl+J                                                     { move-window-down; }
          Mod+Ctrl+K                                                     { move-window-up; }
          Mod+Ctrl+L                                                     { move-column-right; }
          Mod+Home                                                       { focus-column-first; }
          Mod+End                                                        { focus-column-last; }
          Mod+Ctrl+Home                                                  { move-column-to-first; }
          Mod+Ctrl+End                                                   { move-column-to-last; }
          Mod+Shift+Left                                                 { focus-monitor-left; }
          Mod+Shift+Down                                                 { focus-monitor-down; }
          Mod+Shift+Up                                                   { focus-monitor-up; }
          Mod+Shift+Right                                                { focus-monitor-right; }
          Mod+Shift+Ctrl+Left                                            { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+Down                                            { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+Up                                              { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+Right                                           { move-column-to-monitor-right; }
          Mod+Shift+Ctrl+H                                               { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+J                                               { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+K                                               { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+L                                               { move-column-to-monitor-right; }
          Mod+Page_Down                                                  { focus-workspace-down; }
          Mod+Page_Up                                                    { focus-workspace-up; }
          Mod+U                                                          { focus-workspace-down; }
          Mod+I                                                          { focus-workspace-up; }
          Mod+Ctrl+Page_Down                                             { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up                                               { move-column-to-workspace-up; }
          Mod+Ctrl+U                                                     { move-column-to-workspace-down; }
          Mod+Ctrl+I                                                     { move-column-to-workspace-up; }
          Mod+Shift+Page_Down                                            { move-workspace-down; }
          Mod+Shift+Page_Up                                              { move-workspace-up; }
          Mod+Shift+U                                                    { move-workspace-down; }
          Mod+Shift+I                                                    { move-workspace-up; }
          Mod+WheelScrollDown            cooldown-ms=150                 { focus-workspace-down; }
          Mod+WheelScrollUp              cooldown-ms=150                 { focus-workspace-up; }
          Mod+Ctrl+WheelScrollDown       cooldown-ms=150                 { move-column-to-workspace-down; }
          Mod+Ctrl+WheelScrollUp         cooldown-ms=150                 { move-column-to-workspace-up; }
          Mod+WheelScrollRight                                           { focus-column-right; }
          Mod+WheelScrollLeft                                            { focus-column-left; }
          Mod+Ctrl+WheelScrollRight                                      { move-column-right; }
          Mod+Ctrl+WheelScrollLeft                                       { move-column-left; }
          Mod+Shift+WheelScrollDown                                      { focus-column-right; }
          Mod+Shift+WheelScrollUp                                        { focus-column-left; }
          Mod+Ctrl+Shift+WheelScrollDown                                 { move-column-right; }
          Mod+Ctrl+Shift+WheelScrollUp                                   { move-column-left; }
          Mod+1                                                          { focus-workspace 1; }
          Mod+2                                                          { focus-workspace 2; }
          Mod+3                                                          { focus-workspace 3; }
          Mod+4                                                          { focus-workspace 4; }
          Mod+5                                                          { focus-workspace 5; }
          Mod+6                                                          { focus-workspace 6; }
          Mod+7                                                          { focus-workspace 7; }
          Mod+8                                                          { focus-workspace 8; }
          Mod+9                                                          { focus-workspace 9; }
          Mod+Ctrl+1                                                     { move-column-to-workspace 1; }
          Mod+Ctrl+2                                                     { move-column-to-workspace 2; }
          Mod+Ctrl+3                                                     { move-column-to-workspace 3; }
          Mod+Ctrl+4                                                     { move-column-to-workspace 4; }
          Mod+Ctrl+5                                                     { move-column-to-workspace 5; }
          Mod+Ctrl+6                                                     { move-column-to-workspace 6; }
          Mod+Ctrl+7                                                     { move-column-to-workspace 7; }
          Mod+Ctrl+8                                                     { move-column-to-workspace 8; }
          Mod+Ctrl+9                                                     { move-column-to-workspace 9; }
          Mod+BracketLeft                                                { consume-or-expel-window-left; }
          Mod+BracketRight                                               { consume-or-expel-window-right; }
          Mod+Comma                                                      { consume-window-into-column; }
          Mod+Period                                                     { expel-window-from-column; }
          Mod+R                                                          { switch-preset-column-width; }
          Mod+Shift+R                                                    { switch-preset-window-height; }
          Mod+Ctrl+R                                                     { reset-window-height; }
          Mod+F                                                          { maximize-column; }
          Mod+Shift+F                                                    { fullscreen-window; }
          Mod+C                                                          { center-column; }
          Mod+Minus                                                      { set-column-width "-10%"; }
          Mod+Equal                                                      { set-column-width "+10%"; }
          Mod+Shift+Minus                                                { set-window-height "-10%"; }
          Mod+Shift+Equal                                                { set-window-height "+10%"; }
          Mod+Shift+V                                                    { toggle-window-floating; }
          Mod+Shift+W                                                    { toggle-column-tabbed-display; }
        }
      '';
    };
  };
}
