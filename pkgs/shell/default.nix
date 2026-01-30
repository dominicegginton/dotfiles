# center widget for shell:
# - time and date
# - notification indicator
# notification center for shell (popup on click of center widget):
# - list of notifications
# - button to clear all notifications
# right aligned widgets for shell:
# - battery
# - network
# - volume
# quick settings for shell (popup on click of right aligned widgets):
# - button to open system setting - mission center and logout menu
# - adjust brightness slider
# - adjust volume slider
# - toggle wifi on/off (dropdown to select network)
# - toggle bluetooth on/off (dropdown to select device)
# - toggle do not disturb mode on/off (dropdown to set duration)
# - toggle theme light/dark/auto
# left aligned widgets for shell:
# - workspace indicator
# - media player controls (play/pause, next, previous)

{
  lib,
  rustPlatform,
  rustfmt,
  pkg-config,
  gcc,
  glib,
  gtk4,
  gtk4-layer-shell,
  libadwaita,
  cairo,
  swaybg,
}:

rustPlatform.buildRustPackage rec {
  name = "shell";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  runtimeInputs = [ swaybg ];
  nativeBuildInputs = [
    rustfmt
    pkg-config
    gcc
    glib
    swaybg
  ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
    libadwaita
    cairo
  ];

  meta = with lib; {
    description = "Shell";
    mainProgram = name;
    license = licenses.mit;
    maintainers = with maintainers; [ dominicegginton ];
    platforms = platforms.linux;
  };
}
