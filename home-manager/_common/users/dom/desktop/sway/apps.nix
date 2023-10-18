{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dbus-sway-environment
    configure-gtk
    alacritty
    wayland
    xdg-utils
    glib
    dracula-theme
    gnome3.adwaita-icon-theme
    swaylock
    swayidle
    slurp
    wl-clipboard
    bemenu
    mako
    wdisplays
    pulseaudioFull
  ];
}
