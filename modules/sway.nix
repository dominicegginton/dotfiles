{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.sway;

  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
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
in {
  options.modules.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wdisplays # display configuration
      dbus # make dbus-update-activation-environment available in the path
      dbus-sway-environment
      configure-gtk
      xdg-utils # for opening default programs when clicking links
      glib # gsettings
      colloid-gtk-theme # gtk theme
      colloid-icon-theme # icon theme
      gnome3.adwaita-icon-theme # default gnome cursor theme
      flameshot # screenshot functionality
      eww-wayland # eww wayland client
      wlogout # logout functionality
      wl-clipboard # clipboard functionality
      bemenu # wayland clone of dmenu
      swayosd # on screen display
      mako # notification daemon
    ];

    # enable sway window manager
    programs.sway = {
      enable = true;
      wrapperFeatures.base = true;
      wrapperFeatures.gtk = true;
    };

    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };

    # enable light to manage screen brightness
    # user must be in the video group
    programs.light.enable = true;

    # enable pam swaylock service
    security.pam.services.swaylock = {};

    # enable realtime to improve latency and stuttering
    # in high load scernarios
    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];

    # kanshi systemd service
    # kanshi has no options for specifying a config file
    # so we just run it as a service and let it read the config
    # from the default location (~/.config/kanshi/config)
    systemd.user.services.kanshi = {
      description = "kanshi daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
