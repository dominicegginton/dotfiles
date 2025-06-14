{ pkgs
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
  name = "my-shell";
  entry = "app.ts";
  gtk4 = false;
  extraPackages = [
    ags.packages.${system}.gjs
    ags.packages.${system}.astal3
    ags.packages.${system}.astal4
    ags.packages.${system}.io
    ags.packages.${system}.apps
    ags.packages.${system}.mpris
    ags.packages.${system}.network
    ags.packages.${system}.tray
    ags.packages.${system}.wireplumber
    gnome-weather
    gnome-calendar
    mission-center
    curl
    systemd
    libgtop
  ];
}
