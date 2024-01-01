{
  config,
  pkgs,
  ...
}: let
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
      gsettings set $gnome_schema gtk-theme 'Orchis'
    '';
  };
in {
  imports = [
    ../services/dbus.nix # dbus service is needed for xdg-desktop-portal
  ];

  environment.systemPackages = with pkgs; [
    wdisplays # display configuration
    dbus # make dbus-update-activation-environment available in the path
    dbus-sway-environment
    configure-gtk
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    orchis-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursor theme
    swaylock # lockscreen
    swayidle # idle management
    grim # screenshot functionality
    slurp # screenshot functionality
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
    # gtk portal needed to make gtk apps happy
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };

  # enable polkit to allow home manager to manage sway config
  security.polkit.enable = true;

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
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };
}
