{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.display.sway;

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
in

{
  options.modules.display.sway.enable = mkEnableOption "sway";

  config = mkIf cfg.enable {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd sway";
        };
      };
    };
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal
      ];
    };
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.pulseaudio.enable = false;
    services = {
      xserver.enable = true;
      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
      displayManager.sddm.enableHidpi = true;
      displayManager.sddm.theme = "breeze";
      printing.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        jack.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
    };

    systemd.user.services.kanshi = {
      description = "kanshi daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
        Restart = "always";
        RestartSec = 5;
      };
    };
    programs.dconf.enable = true;

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.swaylock = { };
    security.pam.loginLimits = [{
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }];

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
        mpv
        vlc
        waypipe
      ];
    };
  };
}
