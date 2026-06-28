{
  config,
  lib,
  pkgs,
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

  hexToDec =
    c:
    {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
      "A" = 10;
      "B" = 11;
      "C" = 12;
      "D" = 13;
      "E" = 14;
      "F" = 15;
    }
    .${c};

  hexToFloat =
    h:
    let
      clean = lib.removePrefix "#" h;
      r1 = hexToDec (lib.substring 0 1 clean);
      r2 = hexToDec (lib.substring 1 1 clean);
      g1 = hexToDec (lib.substring 2 1 clean);
      g2 = hexToDec (lib.substring 3 1 clean);
      b1 = hexToDec (lib.substring 4 1 clean);
      b2 = hexToDec (lib.substring 5 1 clean);
      r = (r1 * 16 + r2) / 255.0;
      g = (g1 * 16 + g2) / 255.0;
      b = (b1 * 16 + b2) / 255.0;
    in
    "vec3(${toString r}, ${toString g}, ${toString b})";
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
          pkgs.xdg-desktop-portal-wlr
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

          swaynotificationcenter
          swayosd
          wl-clipboard
          my-shell
          my-shell-settings
        ];
      };

      environment.etc."driftwm/wallpapers/dot_grid.glsl".text = ''
        precision highp float;

        varying vec2 v_coords;
        uniform vec2 size;
        uniform vec2 u_camera;

        const vec3 BG_COLOR = ${hexToFloat base0D};
        const vec3 DOT_COLOR = ${hexToFloat "#ffffff"};

        const float DOT_SPACING = 80.0; // canvas pixels between dots
        const float OUTER_RADIUS = 2.5; // outer dot radius in canvas pixels
        const float INNER_RADIUS = 1.5; // inner dot radius in canvas pixels

        void main() {
            vec2 screen_pixel = v_coords * size;
            vec2 canvas_pos = screen_pixel + mod(u_camera, DOT_SPACING);

            vec2 grid = mod(canvas_pos, DOT_SPACING);
            vec2 dist = min(grid, DOT_SPACING - grid);
            float d = length(dist);

            float outer_dot = 1.0 - smoothstep(OUTER_RADIUS - 0.5, OUTER_RADIUS + 0.5, d);
            float inner_dot = 1.0 - smoothstep(INNER_RADIUS - 0.5, INNER_RADIUS + 0.5, d);
            float dot_alpha = outer_dot - inner_dot;

            gl_FragColor = vec4(mix(BG_COLOR, DOT_COLOR, dot_alpha), 1.0);
        }
      '';

      environment.etc."driftwm/config.toml".source =
        (pkgs.formats.toml { }).generate "driftwm-config.toml"
          {
            mod_key = "super";

            focus_follows_mouse = true;
            window_placement = "auto";

            autostart = [
              (lib.getExe pkgs.xwayland-satellite)
              "${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getExe pkgs.cliphist} store"
              "${pkgs.blueman}/bin/blueman-applet"
              (lib.getExe pkgs.my-shell)
            ];

            env = {
              QT_QPA_PLATFORMTHEME = "qt6ct";
            };

            zoom = {
              reset_on_new_window = false;
            };

            cursor = {
              theme = "elementary";
            };

            decorations = {
              bg_color = base00;
              fg_color = base05;
              corner_radius = 10;
              border_width = 0;
              border_color = base01;
              border_color_focused = base0D;
              shadow = true;
            };

            background = {
              type = "shader";
              path = "/etc/driftwm/wallpapers/dot_grid.glsl";
              cache_shader = true;
            };

            xwayland = {
              enabled = true;
              path = lib.getExe pkgs.xwayland-satellite;
            };

            output = {
              outline = {
                color = base00;
              };
            };

            mouse = {
              decoration_resize_snapped = true;
              decoration_fit_snapped = true;
            };

            snap = {
              gap = 10;
              distance = 20;
              corers = true;
              edge_center = true;
            };

            keybindings = {
              "mod+return" = "exec ${lib.getExe pkgs.blackbox-terminal}";
              "mod+space" = "exec ${lib.getExe pkgs.sherlock-launcher} --config-dir /etc/sherlock-launcher/";
              "XF86LaunchA" = "home-toggle";
              "mod+l" = "spawn ${lib.getExe screenLock}";
              "mod+n" = "spawn swaync-client -t";
              "XF86AudioRaiseVolume" = "spawn swayosd-client --output-volume raise";
              "XF86AudioLowerVolume" = "spawn swayosd-client --output-volume lower";
              "XF86AudioMute" = "spawn swayosd-client --output-volume mute-toggle";
              "XF86MonBrightnessUp" = "spawn swayosd-client --brightness raise";
              "XF86MonBrightnessDown" = "spawn swayosd-client --brightness lower";
              "mod+m" = "fit-window-snapped";
              "mod+shift+m" = "fit-window";
              "mod+shift+3" = "spawn ${lib.getExe screenshotOutput}";
              "mod+shift+4" = "spawn ${lib.getExe screenshotRegion}";
              "mod+1" = "go-to 0 1500";
              "mod+shift+escape" = "quit";
              "mod+shift+q" = "close-window";
            };

            gestures = {
              "on-window" = {
                "alt+3-finger-swipe" = "resize-window-snapped";
                "alt+shift+3-finger-swipe" = "resize-window";
              };
            };

            window_rules = [
              {
                app_id = "waybar";
                position = [
                  (-269)
                  19
                ];
                widget = true;
                border_width = 2;
                corner_radius = 10;
              }
              {
                app_id = "waybar";
                position = [
                  132
                  (-247)
                ];
                widget = true;
                border_width = 2;
                corner_radius = 10;
              }
            ];
          };
    }
  );
}
