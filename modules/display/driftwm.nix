{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  # Helper script for screen locking using swaylock-effects
  screenLock = pkgs.writeShellScriptBin "screen-lock" ''
    PATH=${
      lib.makeBinPath [
        pkgs.swaylock-effects
        pkgs.maim
        pkgs.imagemagick
        pkgs.ffmpegthumbnailer
        pkgs.xclip
      ]
    }
    TEMP_IMG=$(mktemp /tmp/screen-lock-XXXXXX.png)
    maim -u | convert - -blur 0x8 -scale 10% -scale 1000% $TEMP_IMG
    swaylock-effects -f -i $TEMP_IMG --effect-blur 10x10
    rm $TEMP_IMG
  '';

  # Helper script for taking full-output screenshots
  screenshotOutput = pkgs.writeShellScriptBin "screenshot-output" ''
    PATH=${
      lib.makeBinPath [
        pkgs.wl-clipboard
        pkgs.gradia
      ]
    }
    gradia --screenshot=FULL
  '';

  # Helper script for taking region screenshots
  screenshotRegion = pkgs.writeShellScriptBin "screenshot-region" ''
    PATH=${
      lib.makeBinPath [
        pkgs.wl-clipboard
        pkgs.gradia
      ]
    }
    gradia --screenshot
  '';
in

{
  options.display.driftwm.enable = lib.mkEnableOption "DriftWM";

  config = lib.mkIf config.display.driftwm.enable (
    with config.scheme.withHashtag;
    {
      # Enable hardware accelerated graphics drivers
      hardware.graphics.enable = lib.mkDefault true;

      # Enable hardware bluetooth support
      hardware.bluetooth.enable = lib.mkDefault true;

      # Enable UNIX application-level authorizations via Polkit
      security.polkit.enable = lib.mkDefault true;

      # Enable Swaylock PAM service
      security.pam.services.swaylock = lib.mkDefault { };

      # XDG Portal configuration for desktop integration
      xdg.portal = {
        enable = lib.mkDefault true;
        wlr.enable = lib.mkDefault true;
        configPackages = lib.mkDefault [ pkgs.driftwm ];
        extraPortals = lib.mkDefault [
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      # Standard XDG support
      xdg.autostart.enable = lib.mkDefault true;
      xdg.menus.enable = lib.mkDefault true;
      xdg.icons.enable = lib.mkDefault true;

      services.graphical-desktop.enable = true;

      # Core system services
      services.printing.enable = true;
      services.pipewire.enable = true;
      services.gnome.gnome-keyring.enable = true;
      services.power-profiles-daemon.enable = true;

      services.displayManager.gdm.enable = true;
      services.displayManager.sessionPackages = [ pkgs.driftwm ];

      systemd.packages = [ pkgs.driftwm ];
      systemd.user.services.driftwm = {
        environment = {
          DRIFTWM_CONFIG = "/etc/driftwm/config.toml";
        };
      };

      # Typography and icon configuration
      fonts = {
        packages = with pkgs; [
          noto-fonts-color-emoji
          ibm-plex
        ];
        fontconfig = {
          enable = lib.mkForce true;
          antialias = lib.mkForce true;
          hinting.autohint = lib.mkForce true;
          hinting.enable = lib.mkForce true;
          defaultFonts = {
            emoji = [ "Noto Color Emoji" ];
            serif = [ "Ibm Plex Serif" ];
            sansSerif = [ "Ibm Plex Sans" ];
            monospace = [
              "Ibm Plex Mono"
              "Noto Nerd Font Mono"
            ];
          };
        };
      };

      # Core GUI utilities and environment configuration
      environment = {
        variables = {
          NIXOS_OZONE_WL = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          MOZ_ENABLE_WAYLAND = "1";
          MOZ_DBUS_REMOTE = "1";
          MOZ_USE_XINPUT2 = "1";
          MOZ_USE_XINPUT2_BY_DEFAULT = "1";
          DRIFTWM_CONFIG = "/etc/driftwm/config.toml";
        };
        systemPackages = with pkgs; [
          gnome-keyring

          mission-center
          wdisplays
          swaysettings

          nautilus
          sushi
          clapper
          loupe
          evince
          gnome-font-viewer
          gnome-calendar
          gnome-logs
          gnome-contacts
          gnome-firmware

          sc
        ];
      };

      environment.etc."driftwm/config.toml".text = ''
        mod_key = "super"

        autostart = [
          "${lib.getExe pkgs.xwayland-satellite}",
          "${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getExe pkgs.cliphist} store",
          "${pkgs.blueman}/bin/blueman-applet"
        ]

        [input.trackpad]
        tap_to_click = true
        natural_scroll = true

        [decorations]
        bg_color = "${base00}"
        fg_color = "${base05}"
        corner_radius = 15 
        shadow = true
        border_width = 1
        border_color = "${base01}"
        border_color_focused = "${base0D}"

        [keybindings]
        "mod+return" = "exec ${lib.getExe pkgs.blackbox-terminal}"
        "mod+space" = "exec ${lib.getExe pkgs.sherlock-launcher} --config-dir /etc/sherlock-launcher/"
        "mod+shift+q" = "close-window"
        "mod+shift+e" = "quit"
        "ctrl+alt+delete" = "spawn ${lib.getExe pkgs.mission-center}"

        "Mod+shift+l" = "spawn ${lib.getExe screenLock}"
        "Mod+shift+3" = "spawn ${lib.getExe screenshotOutput}"
        "Mod+shift+4" = "spawn ${lib.getExe screenshotRegion}"

        "XF86AudioPlay" = "spawn ${pkgs.playerctl}/bin/playerctl play-pause"
        "XF86AudioPause" = "spawn ${pkgs.playerctl}/bin/playerctl play-pause"
        "XF86AudioStop" = "spawn ${pkgs.playerctl}/bin/playerctl stop"
        "XF86AudioNext" = "spawn ${pkgs.playerctl}/bin/playerctl next"
        "XF86AudioPrev" = "spawn ${pkgs.playerctl}/bin/playerctl previous"
        "XF86AudioRaiseVolume" = "spawn ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
        "XF86AudioLowerVolume" = "spawn ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
        "XF86AudioMute" = "spawn ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"

        "mod+left" = "center-nearest left"
        "mod+right" = "center-nearest right"
        "mod+up" = "center-nearest up"
        "mod+down" = "center-nearest down"
        "mod+h" = "center-nearest left"
        "mod+l" = "center-nearest right"
        "mod+k" = "center-nearest up"
        "mod+j" = "center-nearest down"

        "mod+shift+left" = "nudge-window left"
        "mod+shift+right" = "nudge-window right"
        "mod+shift+up" = "nudge-window up"
        "mod+shift+down" = "nudge-window down"
        "mod+shift+h" = "nudge-window left"
        "mod+shift+l" = "nudge-window right"
        "mod+shift+k" = "nudge-window up"
        "mod+shift+j" = "nudge-window down"

        "mod+ctrl+left" = "pan-viewport left"
        "mod+ctrl+right" = "pan-viewport right"
        "mod+ctrl+up" = "pan-viewport up"
        "mod+ctrl+down" = "pan-viewport down"
        "mod+ctrl+h" = "pan-viewport left"
        "mod+ctrl+l" = "pan-viewport right"
        "mod+ctrl+k" = "pan-viewport up"
        "mod+ctrl+j" = "pan-viewport down"

        "mod+equal" = "zoom-in"
        "mod+minus" = "zoom-out"
        "mod+0" = "zoom-reset"
        "mod+f" = "toggle-fullscreen"
        "mod+m" = "fit-window"

        [[window_rules]]
        app_id = "/^(org.gnome.Nautilus|org.gnome.Evince|org.gnome.Calendar|org.gnome.FontViewer|org.gnome.Sushi|org.gnome.Clocks|org.gnome.Logs|org.gnome.Todo|org.gnome.Maps|org.gnome.Contacts|org.gnome.Photos|org.gnome.Cheese|org.gnome.Music|org.gnome.Videos|wdisplays|com.jaoushingan.WaydroidHelper)$/"
        decoration = "client"
      '';
    }
  );
}
