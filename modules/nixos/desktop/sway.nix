{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.sway;

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

  kanshi-deamon = rec {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
      Restart = "always";
      RestartSec = 5;
    };
  };

  login-limits = rec {
    domain = "@users";
    item = "rtprio";
    type = "-";
    value = 1;
  };
in {
  options.modules.desktop.sway.enable = mkEnableOption "sway";

  config = mkIf cfg.enable {
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.wlr.enable = true;
    xdg.portal.config.common.default = "*";
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal
    ];
    programs.dconf.enable = true;
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.pulseaudio.enable = false;
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.displayManager.sddm.wayland.enable = true;
    services.xserver.displayManager.sddm.enableHidpi = true;
    services.xserver.displayManager.sddm.theme = "breeze";
    services.printing.enable = true;
    services.pipewire = rec {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

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
        pcmanfm
        swayimg
        pipewire
        alsa-utils
        pulseaudio
        pulsemixer
        pavucontrol
      ];
    };

    fonts.fontconfig = rec {
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
    fonts.packages = with pkgs; let
      nerd-fonts = ["FiraCode" "SourceCodePro" "UbuntuMono"];
    in [
      font-manager
      (nerdfonts.override {fonts = nerd-fonts;})
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
    systemd.user.services.kanshi = kanshi-deamon;
    security.pam.services.swaylock = {};
    security.pam.loginLimits = [login-limits];
  };
}
