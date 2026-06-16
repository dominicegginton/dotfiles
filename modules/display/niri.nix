{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  # Helper for KDL generation
  toKDL = self.inputs.home-manager.lib.hm.generators.toKDL { };

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

  # Helper script to sync GNOME background settings with swaybg
  swayWallpaper = pkgs.writeShellScriptBin "sway-wallpaper" ''
    PATH=${
      lib.makeBinPath [
        pkgs.glib
        pkgs.swaybg
        pkgs.procps
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.findutils
      ]
    }

    update_wallpaper() {
      THEME=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
      if [ "$THEME" = "prefer-dark" ]; then
        IMAGE=$(gsettings get org.gnome.desktop.background picture-uri-dark | tr -d "'" | sed 's/file:\/\///')
      else
        IMAGE=$(gsettings get org.gnome.desktop.background picture-uri | tr -d "'" | sed 's/file:\/\///')
      fi

      if [ -f "$IMAGE" ]; then
        # Use pkill to clear old instances, then start new one
        pkill swaybg || true
        swaybg -i "$IMAGE" -m fill &
      fi
    }

    # Initial set
    update_wallpaper

    # Monitor for changes and update
    gsettings monitor org.gnome.desktop.interface color-scheme | while read -r _; do update_wallpaper; done &
    gsettings monitor org.gnome.desktop.background picture-uri | while read -r _; do update_wallpaper; done &
    gsettings monitor org.gnome.desktop.background picture-uri-dark | while read -r _; do update_wallpaper; done &

    wait
  '';
in

{
  options.display.niri.enable = lib.mkEnableOption "Niri";

  config = lib.mkIf config.display.niri.enable (
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
        configPackages = lib.mkDefault [ pkgs.niri ];
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

      # Display manager configuration
      services.displayManager.gdm.enable = true;
      services.geoclue2.enableDemoAgent = lib.mkDefault true;

      # Systemd service to sync GNOME wallpaper settings to swaybg
      systemd.user.services.sway-wallpaper = {
        description = "Sync GNOME wallpaper settings to swaybg";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${swayWallpaper}/bin/sway-wallpaper";
          Restart = "on-failure";
        };
      };

      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };

      environment.etc."niri/config.kdl".text =
        let
          # Helper to render repeated nodes
          mkRepeated = name: list: lib.concatMapStringsSep "\n" (value: toKDL { "${name}" = value; }) list;

          # Define repeated nodes
          spawnAtStartup = [
            [ (lib.getExe pkgs.xwayland-satellite) ]
            [ (lib.getExe pkgs.my-shell) ]
            [
              "${pkgs.wl-clipboard}/bin/wl-paste"
              "--watch"
              (lib.getExe pkgs.cliphist)
              "store"
            ]
          ]
          ++ (lib.optional config.hardware.bluetooth.enable [ "${pkgs.blueman}/bin/blueman-applet" ])
          ++ (lib.optional config.services.printing.enable [
            "${pkgs.cups}/bin/cupsd"
            "-l"
          ])
          ++ (lib.optional config.services.printing.enable [ "${pkgs.cups}/bin/cupsenable" ]);

          layerRules = [
            {
              match._props.namespace = "^notifications$";
              block-out-from = "screencast";
            }
          ];

          windowRules = [
            {
              # Global defaults for all windows
              draw-border-with-background = false;
              geometry-corner-radius = 0;
              clip-to-geometry = true;
            }
            {
              # Visual feedback when a window is being recorded
              match._props.is-window-cast-target = true;
              focus-ring = {
                active-color = red;
                inactive-color = red;
              };
              border = {
                active-color = red;
                inactive-color = red;
              };
              tab-indicator = {
                active-color = red;
                inactive-color = red;
              };
            }
            {
              # Styling for floating windows
              match._props.is-floating = true;
              geometry-corner-radius = 0;
              shadow = {
                on = [ ];
                softness = 40;
                spread = 5;
                offset._props = {
                  x = 0;
                  y = 5;
                };
                draw-behind-window = true;
                color = "${base07}40";
              };
            }
            {
              # Applications that should open floating by default
              match._props.app-id = "^(org.gnome.Nautilus|org.gnome.Evince|org.gnome.Calendar|org.gnome.FontViewer|org.gnome.Sushi|org.gnome.Clocks|org.gnome.Logs|org.gnome.Todo|org.gnome.Maps|org.gnome.Contacts|org.gnome.Photos|org.gnome.Cheese|org.gnome.Music|org.gnome.Videos|wdisplays|com.jaoushingan.WaydroidHelper)$";
              open-floating = true;
              open-focused = true;
              default-column-width.proportion = 0.4;
              default-window-height.proportion = 0.4;
            }
          ];
        in
        ''
          ${toKDL {
            # Global compositor settings
            prefer-no-csd = [ ];

            # UI element visibility
            hotkey-overlay = {
              skip-at-startup = [ ];
              hide-not-bound = [ ];
            };

            # Input device configuration
            input = {
              mod-key = "Super";
              mod-key-nested = "Alt";
              warp-mouse-to-focus = [ ];
              workspace-auto-back-and-forth = [ ];
              mouse.accel-profile = "flat";
              touchpad = {
                tap = [ ];
                natural-scroll = [ ];
                accel-profile = "flat";
              };
              trackpoint = {
                natural-scroll = [ ];
                accel-profile = "flat";
              };
            };

            # Handling of hardware switch events (lid, tablet mode)
            switch-events = {
              lid-close.spawn = [
                "notify-send"
                "The laptop lid is closed!"
              ];
              lid-open.spawn = [
                "notify-send"
                "The laptop lid is open!"
              ];
              tablet-mode-on.spawn = [
                "bash"
                "-c"
                "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true"
              ];
              tablet-mode-off.spawn = [
                "bash"
                "-c"
                "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false"
              ];
            };

            # Tiling layout configuration
            layout = {
              gaps = 0;
              center-focused-column = "never";
              struts = {
                left = 0;
                right = 0;
                top = 0;
                bottom = 0;
              };
              focus-ring = {
                width = 2;
                active-color = magenta;
                inactive-color = base07;
                urgent-color = yellow;
              };
              border = {
                width = 0;
                active-color = magenta;
                inactive-color = base07;
                urgent-color = yellow;
              };
              tab-indicator = {
                width = 2;
                active-color = blue;
                inactive-color = base07;
                urgent-color = yellow;
              };
              default-column-width.proportion = 0.75;
              preset-column-widths._children = [
                { proportion._args = [ 0.25 ]; }
                { proportion._args = [ 0.5 ]; }
                { proportion._args = [ 0.75 ]; }
              ];
            };

            # Overview mode settings
            overview = {
              zoom = 1.0;
              backdrop-color = base07;
            };

            # Keyboard shortcuts
            binds = {
              # System and Shell controls
              "Mod+Shift+Slash".show-hotkey-overlay = [ ];
              "Mod+O".toggle-overview = [ ];
              "Mod+Shift+Q".close-window = [ ];
              "Mod+Return".spawn = [ (lib.getExe pkgs.blackbox-terminal) ];
              "Mod+Space".spawn = [
                (lib.getExe pkgs.sherlock-launcher)
                "--config-dir"
                "/etc/sherlock-launcher/"
              ];
              "Mod+Shift+L".spawn = [ (lib.getExe screenLock) ];
              "Mod+Shift+3".spawn = [ (lib.getExe screenshotOutput) ];
              "Mod+Shift+4".spawn = [ (lib.getExe screenshotRegion) ];
              "Mod+Shift+E".quit = [ ];
              "Mod+Shift+P".power-off-monitors = [ ];
              "Ctrl+Alt+Delete".spawn = [ (lib.getExe pkgs.mission-center) ];

              # Media keys
              "XF86AudioPlay".spawn = [
                "${pkgs.playerctl}/bin/playerctl"
                "play-pause"
              ];
              "XF86AudioPause".spawn = [
                "${pkgs.playerctl}/bin/playerctl"
                "play-pause"
              ];
              "XF86AudioStop".spawn = [
                "${pkgs.playerctl}/bin/playerctl"
                "stop"
              ];
              "XF86AudioNext".spawn = [
                "${pkgs.playerctl}/bin/playerctl"
                "next"
              ];
              "XF86AudioPrev".spawn = [
                "${pkgs.playerctl}/bin/playerctl"
                "previous"
              ];
              "XF86AudioRaiseVolume".spawn = [
                "${pkgs.pulseaudio}/bin/pactl"
                "set-sink-volume"
                "@DEFAULT_SINK@"
                "+5%"
              ];
              "XF86AudioLowerVolume".spawn = [
                "${pkgs.pulseaudio}/bin/pactl"
                "set-sink-volume"
                "@DEFAULT_SINK@"
                "-5%"
              ];
              "XF86AudioMute".spawn = [
                "${pkgs.pulseaudio}/bin/pactl"
                "set-sink-mute"
                "@DEFAULT_SINK@"
                "toggle"
              ];

              # Focus management
              "Mod+Left".focus-column-left = [ ];
              "Mod+Down".focus-window-down = [ ];
              "Mod+Up".focus-window-up = [ ];
              "Mod+Right".focus-column-right = [ ];
              "Mod+H".focus-column-left = [ ];
              "Mod+J".focus-window-down = [ ];
              "Mod+K".focus-window-up = [ ];
              "Mod+L".focus-column-right = [ ];

              # Window/Column movement
              "Mod+Ctrl+Left".move-column-left = [ ];
              "Mod+Ctrl+Down".move-window-down = [ ];
              "Mod+Ctrl+Up".move-window-up = [ ];
              "Mod+Ctrl+Right".move-column-right = [ ];
              "Mod+Ctrl+H".move-column-left = [ ];
              "Mod+Ctrl+J".move-window-down = [ ];
              "Mod+Ctrl+K".move-window-up = [ ];
              "Mod+Ctrl+L".move-column-right = [ ];

              # Jump to start/end
              "Mod+Home".focus-column-first = [ ];
              "Mod+End".focus-column-last = [ ];
              "Mod+Ctrl+Home".move-column-to-first = [ ];
              "Mod+Ctrl+End".move-column-to-last = [ ];

              # Multi-monitor focus
              "Mod+Shift+Left".focus-monitor-left = [ ];
              "Mod+Shift+Down".focus-monitor-down = [ ];
              "Mod+Shift+Up".focus-monitor-up = [ ];
              "Mod+Shift+Right".focus-monitor-right = [ ];

              # Move between monitors
              "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = [ ];
              "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = [ ];
              "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = [ ];
              "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = [ ];
              "Mod+Shift+Ctrl+H".move-column-to-monitor-left = [ ];
              "Mod+Shift+Ctrl+J".move-column-to-monitor-down = [ ];
              "Mod+Shift+Ctrl+K".move-column-to-monitor-up = [ ];
              "Mod+Shift+Ctrl+L".move-column-to-monitor-right = [ ];

              # Workspace navigation
              "Mod+Page_Down".focus-workspace-down = [ ];
              "Mod+Page_Up".focus-workspace-up = [ ];
              "Mod+U".focus-workspace-down = [ ];
              "Mod+I".focus-workspace-up = [ ];

              # Move windows between workspaces
              "Mod+Ctrl+Page_Down".move-column-to-workspace-down = [ ];
              "Mod+Ctrl+Page_Up".move-column-to-workspace-up = [ ];
              "Mod+Ctrl+U".move-column-to-workspace-down = [ ];
              "Mod+Ctrl+I".move-column-to-workspace-up = [ ];

              # Workspace reordering
              "Mod+Shift+Page_Down".move-workspace-down = [ ];
              "Mod+Shift+Page_Up".move-workspace-up = [ ];
              "Mod+Shift+U".move-workspace-down = [ ];
              "Mod+Shift+I".move-workspace-up = [ ];

              # Mouse wheel shortcuts (workspace switching)
              "Mod+WheelScrollDown" = {
                _props = {
                  cooldown-ms = 150;
                };
                focus-workspace-down = [ ];
              };
              "Mod+WheelScrollUp" = {
                _props = {
                  cooldown-ms = 150;
                };
                focus-workspace-up = [ ];
              };
              "Mod+Ctrl+WheelScrollDown" = {
                _props = {
                  cooldown-ms = 150;
                };
                move-column-to-workspace-down = [ ];
              };
              "Mod+Ctrl+WheelScrollUp" = {
                _props = {
                  cooldown-ms = 150;
                };
                move-column-to-workspace-up = [ ];
              };

              # Mouse wheel shortcuts (horizontal column navigation)
              "Mod+WheelScrollRight".focus-column-right = [ ];
              "Mod+WheelScrollLeft".focus-column-left = [ ];
              "Mod+Ctrl+WheelScrollRight".move-column-right = [ ];
              "Mod+Ctrl+WheelScrollLeft".move-column-left = [ ];

              "Mod+Shift+WheelScrollDown".focus-column-right = [ ];
              "Mod+Shift+WheelScrollUp".focus-column-left = [ ];
              "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = [ ];
              "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = [ ];

              # Direct workspace access
              "Mod+1".focus-workspace = 1;
              "Mod+2".focus-workspace = 2;
              "Mod+3".focus-workspace = 3;
              "Mod+4".focus-workspace = 4;
              "Mod+5".focus-workspace = 5;
              "Mod+6".focus-workspace = 6;
              "Mod+7".focus-workspace = 7;
              "Mod+8".focus-workspace = 8;
              "Mod+9".focus-workspace = 9;

              # Move columns to specific workspaces
              "Mod+Ctrl+1".move-column-to-workspace = 1;
              "Mod+Ctrl+2".move-column-to-workspace = 2;
              "Mod+Ctrl+3".move-column-to-workspace = 3;
              "Mod+Ctrl+4".move-column-to-workspace = 4;
              "Mod+Ctrl+5".move-column-to-workspace = 5;
              "Mod+Ctrl+6".move-column-to-workspace = 6;
              "Mod+Ctrl+7".move-column-to-workspace = 7;
              "Mod+Ctrl+8".move-column-to-workspace = 8;
              "Mod+Ctrl+9".move-column-to-workspace = 9;

              # Tiling operations (consume/expel windows)
              "Mod+BracketLeft".consume-or-expel-window-left = [ ];
              "Mod+BracketRight".consume-or-expel-window-right = [ ];
              "Mod+Comma".consume-window-into-column = [ ];
              "Mod+Period".expel-window-from-column = [ ];

              # Sizing and Layout toggles
              "Mod+R".switch-preset-column-width = [ ];
              "Mod+Shift+R".switch-preset-window-height = [ ];
              "Mod+Ctrl+R".reset-window-height = [ ];
              "Mod+F".maximize-column = [ ];
              "Mod+Shift+F".fullscreen-window = [ ];
              "Mod+C".center-column = [ ];
              "Mod+Minus".set-column-width = "-10%";
              "Mod+Equal".set-column-width = "+10%";
              "Mod+Shift+Minus".set-window-height = "-10%";
              "Mod+Shift+Equal".set-window-height = "+10%";
              "Mod+Shift+W".toggle-column-tabbed-display = [ ];
            };
          }}
          ${mkRepeated "output" [
            {
              _args = [ "eDP-1" ];
              scale = 1.0;
            }
          ]}
          ${mkRepeated "spawn-at-startup" spawnAtStartup}
          ${mkRepeated "window-rule" windowRules}
          ${mkRepeated "layer-rule" layerRules}
        '';

      # Additional programs to enable with Niri
      programs = {
        dconf.enable = lib.mkForce true;
        firefox.enable = true;
        xwayland.enable = lib.mkDefault true;
        sherlock-launcher.enable = true;
      };

      # Font configuration for the session
      fonts = {
        enableDefaultPackages = lib.mkForce false;
        fontDir.enable = lib.mkForce true;
        packages = with pkgs; [
          font-manager
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

      # Environment variables and user packages
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
          gnome-keyring

          my-shell
          my-shell-settings
          mission-center
          wdisplays
          swaysettings

          lock

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
        ];
      };
    }
  );
}
