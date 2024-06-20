{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.modules.desktop.sway;

  dbus-sway-environment = pkgs.writeTextFile {
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

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Redmond97'
        gsettings set $gnome_schema icon-theme 'Redmond97'
        gsettings set $gnome_schema cursor-theme 'Adwaita'
      '';
  };

  kanshi-deamon = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
      Restart = "always";
      RestartSec = 5;
    };
  };

  login-limits = {
    domain = "@users";
    item = "rtprio";
    type = "-";
    value = 1;
  };
in

with lib;

{
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
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.enableHidpi = true;
    services.displayManager.sddm.theme = "breeze";
    services.gnome.gnome-keyring.enable = true;
    services.printing.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    programs.sway = {
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
        wpa_supplicant_gui
      ];
    };

    fonts.fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts.serif = [ "Source Serif" ];
      defaultFonts.sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
      defaultFonts.monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" ];
      defaultFonts.emoji = [ "Noto Color Emoji" ];
      hinting.autohint = false;
      hinting.enable = true;
      hinting.style = "full";
      subpixel.rgba = "rgb";
      subpixel.lcdfilter = "light";
    };
    fonts.packages = with pkgs; let
      nerd-fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ];
    in
    [
      font-manager
      (nerdfonts.override { fonts = nerd-fonts; })
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
    security.pam.services.swaylock = { };
    security.pam.loginLimits = [ login-limits ];
  };
}
