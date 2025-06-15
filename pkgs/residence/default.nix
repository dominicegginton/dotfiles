{ lib
, pkgs
, ags
, system
, gnome-weather
, gnome-calendar
, mission-center
, curl
, systemd
, libgtop
, ...
}:

ags.lib.bundle {
  inherit pkgs;
  src = ./.;
  name = (lib.importJSON ./package.json).name;
  entry = "app.ts";
  gtk4 = false;
  extraPackages = [
    ags.packages.${system}.gjs
    ags.packages.${system}.astal3
    ags.packages.${system}.astal4
    ags.packages.${system}.io
    ags.packages.${system}.apps
    ags.packages.${system}.mpris
    ags.packages.${system}.wireplumber
    mission-center
    curl
    systemd
    libgtop
  ];
}
