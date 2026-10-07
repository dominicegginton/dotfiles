{ pkgs }:

let
  inherit (pkgs.lib) recurseIntoAttrs;
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  apps = recurseIntoAttrs {
    inherit (pkgs)
      clapper
      evince
      gnome-calendar
      gnome-contacts
      gnome-firmware
      gnome-font-viewer
      gnome-keyring
      gnome-logs
      loupe
      mission-center
      my-shell
      my-shell-settings
      nautilus
      sushi
      swaysettings
      wdisplays
      ;
  };

  utils = recurseIntoAttrs {
    inherit (pkgs)
      coreutils
      ffmpegthumbnailer
      findutils
      glib
      gnugrep
      gradia
      imagemagick
      maim
      procps
      swaybg
      swaylock-effects
      wl-clipboard
      xclip
      ;
  };

  inherit scripts;
}
