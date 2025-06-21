{ config, lib, pkgs, ... }:

with config.scheme.withHashtag;

{
  config = lib.mkIf config.programs.niri.enable {
    hardware.graphics.enable = true;
    xdg = {
      autostart.enable = true;
      menus.enable = true;
      icons.enable = true;
      portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        configPackages = [ pkgs.niri ];
      };
    };
    services.tlp.enable = true;
    services.printing.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = lib.mkIf config.hardware.bluetooth.enable ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
    environment.etc."tofi/config".text = ''
      corner-radius = 20
      border-width = 0
      outline-width = 4
      text-cursor-style = bar
      anchor = center
      text-color = ${base07}
      prompt-color = ${magenta}
      selection-color = ${magenta}
      background-color = ${base00}
      outline-color = ${magenta}
    '';
    environment.etc."dunst/dunstrc".text = ''
      [global]
      follow = keyboard
      timeout = 0
      frame_color = "${base00}"
      separator_color = "${base00}"
      [low]
      msg_urency = "low"
      frame_color = "${base07}"
      separator_color = "${base07}"
      [normal]
      msg_urency = "normal"
      frame_color = "${base07}"
      separator_color = "${base07}"
      [critical]
      msg_urency = "critical"
      frame_color = "${yellow}"
      separator_color = "${yellow}"
    '';
    environment.etc."niri/config.kdl".text = ''
      prefer-no-csd
      spawn-at-startup "${lib.getExe pkgs.swaybg}" "--image" "${./background.jpg}" "--mode" "fill"
      spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${lib.getExe pkgs.cliphist}" "store"
      spawn-at-startup "${lib.getExe pkgs.dunst}" "--config" "${config.environment.etc."dunst/dunstrc".source}"
      spawn-at-startup "${lib.getExe pkgs.wlsunset}"
      ${lib.optionalString config.hardware.bluetooth.enable ''spawn-at-startup "${pkgs.tlp}/bin/bluetooth" "on"''}
      ${lib.optionalString config.hardware.bluetooth.enable ''spawn-at-startup "${pkgs.blueman}/bin/blueman-applet"''}
      ${lib.optionalString config.hardware.bluetooth.enable ''spawn-at-startup "${pkgs.bluez}/bin/bluetoothctl" "power" "on"''}
      ${lib.optionalString config.services.printing.enable ''spawn-at-startup "${lib.getExe pkgs.cups-browsed}"''}
      environment {
        DISPLAY ":0"
      }
      hotkey-overlay {
        skip-at-startup
      }
      input {
        mod-key "Super"
        mod-key-nested "Alt"
        warp-mouse-to-focus
        workspace-auto-back-and-forth
        keyboard {
          numlock
          xkb {
            layout "US"
          }
        }
        touchpad {
          tap
          natural-scroll
          scroll-method "two-finger"
        }
        mouse {
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
      layout {
        gaps 16
        center-focused-column "on-overflow"
        always-center-single-column
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
          width 1
          active-color "${magenta}"
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
        zoom 0.7
        backdrop-color "${base00}"
      }
      binds {
        Mod+Shift+Slash                                                { show-hotkey-overlay; }
        Mod+O                repeat=false                              { toggle-overview; }
        Mod+Shift+Q                                                    { close-window; }
        Mod+T                hotkey-overlay-title="Terminal"           { spawn "${lib.getExe pkgs.alacritty}"; }
        Mod+Space            hotkey-overlay-title="Run an Application" { spawn "${lib.getExe pkgs.wldash}"; }
        Mod+Shift+Escape     hotkey-overlay-title="System Manage"      { spawn "${lib.getExe pkgs.wlogout}"; }
        Mod+Shift+L          hotkey-overlay-title="Lock the Screen"    { spawn "${lib.getExe pkgs.swaylock}" "--image" "${./background.jpg}"; }
        Mod+Shift+3          hotkey-overlay-title="Screenshot: Output" { spawn "${lib.getExe (pkgs.writeShellScriptBin "screenshot-output" ''PATH=${lib.makeBinPath [ pkgs.uutils-coreutils-noprefix pkgs.wl-clipboard ]} ${lib.getExe pkgs.grim} -o $(${lib.getExe pkgs.niri} msg focused-output | grep Output | awk -F '[()]' '{print $2}') - | ${lib.getExe pkgs.swappy} -f -'')}"; }
        Mod+Shift+4          hotkey-overlay-title="Screenshot: Region" { spawn "${lib.getExe (pkgs.writeShellScriptBin "screenshot-region" ''PATH=${lib.makeBinPath [ pkgs.wl-clipboard ]} ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.swappy} -f -'')}"; }
        Mod+Shift+E                                                    { quit; }
        Mod+Shift+P                                                    { power-off-monitors; }
        Mod+Shift+H          hotkey-overlay-title="Clipboard: History" { spawn "${lib.getExe (pkgs.writeShellScriptBin "clipboard-history" ''${lib.getExe pkgs.cliphist} list | ${lib.getExe pkgs.tofi} --config ${config.environment.etc."tofi/config".source} --font ${pkgs.ibm-plex}/share/donts/opentype/IBMPlexSans-Text.otf | ${lib.getExe pkgs.cliphist} decode | ${pkgs.wl-clipboard}/bin/wl-copy'')}"; }
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
      window-rule {
        match
        draw-border-with-background false
        geometry-corner-radius 4.0 4.0 4.0 4.0
        clip-to-geometry true
      }
    '';
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.displayManager.ly.enable = true;
    services.displayManager.sessionPackages = [ pkgs.niri ];
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      resources
      systemdgenie
      wpa_supplicant_gui
      wdisplays
      pavucontrol
      nautilus
      sushi
      clapper
      nomacs
      file-roller
      evince
    ];
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        antialias = true;
        defaultFonts.serif = [ "Ibm Plex Serif" ];
        defaultFonts.sansSerif = [ "Ibm Plex Sans" ];
        defaultFonts.monospace = [ "Ibm Plex Mono" "Noto Nerd Font Mono" ];
        defaultFonts.emoji = [ "Noto Color Emoji" ];
        hinting.autohint = true;
        hinting.enable = true;
        hinting.style = "full";
        subpixel.rgba = "rgb";
        subpixel.lcdfilter = "light";
      };
      packages = with pkgs; [
        font-manager
        nerd-fonts.noto
        noto-fonts-emoji
        ibm-plex
      ];
    };
  };
}
