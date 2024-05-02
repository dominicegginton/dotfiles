{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop;
in {
  options.modules.desktop = rec {
    sway.enable = mkEnableOption "sway";
    gamescope.enable = mkEnableOption "gamescope";
    packages = mkOption {type = types.listOf types.package;};
  };

  config = let
    dbus-sway-environment = pkgs.writeTextFile rec {
      name = "dbus-sway-environment";
      destination = "/bin/dbus-sway-environment";
      executable = true;
      text = ''
        systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
        systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
        systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
    };

    configure-gtk = pkgs.writeTextFile rec {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Colloid'
      '';
    };
  in
    mkIf cfg.sway.enable rec {
      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.pulseaudio.enable = false;
      programs.light.enable = true;
      programs.dconf.enable = true;
      services.xserver.layout = "gb";
      services.printing.enable = true;
      services.pipewire.enable = true;
      services.pipewire.alsa.enable = true;
      services.pipewire.jack.enable = true;
      services.pipewire.pulse.enable = true;
      services.pipewire.wireplumber.enable = true;

      programs.sway = rec {
        enable = true;
        wrapperFeatures.base = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          dbus
          dbus-sway-environment
          configure-gtk
          xdg-utils
          glib
          colloid-gtk-theme
          colloid-icon-theme
          gnome3.adwaita-icon-theme
          wl-gammactl
          flameshot
          slurp
          wl-clipboard
          wlrctl
          libnotify
          mako
          nwg-displays
          kanshi
          mmfm
          pcmanfm
          swayimg
          mpvpaper
        ];
      };

      xdg.portal = rec {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
          xdg-desktop-portal
        ];
      };

      fonts = rec {
        enableDefaultPackages = false;
        fontDir.enable = true;
        fontconfig = rec {
          enable = true;
          antialias = true;
          defaultFonts.serif = ["Source Serif"];
          defaultFonts.sansSerif = ["Work Sans" "Fira Sans" "FiraGO"];
          defaultFonts.monospace = ["FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono"];
          defaultFonts.emoji = ["Noto Color Emoji"];
          hinting.autohint = false;
          hinting.enable = true;
          hinting.style = "full";
          subpixel.rgba = "rgb";
          subpixel.lcdfilter = "light";
        };
        packages = with pkgs; [
          font-manager
          fira
          fira-go
          joypixels
          liberation_ttf
          noto-fonts-emoji
          source-serif
          ubuntu_font_family
          work-sans
          jetbrains-mono
          ibm-plex
        ];
      };

      boot.plymouth = rec {
        enable = true;
        theme = "spinner";
      };

      systemd.user.services.kanshi = rec {
        description = "kanshi daemon";
        serviceConfig = {
          Type = "simple";
          ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
          Restart = "always";
          RestartSec = 5;
        };
      };

      security.pam = rec {
        services.swaylock = {};
        loginLimits = [
          {
            domain = "@users";
            item = "rtprio";
            type = "-";
            value = 1;
          }
        ];
      };

      environment.systemPackages = with pkgs;
        [
          de
          pipewire
          alsa-utils
          pulseaudio
          pulsemixer
          pavucontrol
        ]
        ++ cfg.packages;
    };
}
