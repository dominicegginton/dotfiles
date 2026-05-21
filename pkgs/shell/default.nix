# Shell component features:
# - Center widget: Time, date, and notification indicator
# - Notification center: List and management of notifications
# - Right-aligned widgets: Battery, network, volume
# - Quick settings: System controls, toggles, and sliders

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

  # Build requirements and runtime dependencies
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
