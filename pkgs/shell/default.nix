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
# - top line of buttons:
#   - battery icon and percentage (opens battery settings)
#   - screenshot button (opens screenshot tool)
#   - settings button (opens system settings)
#   - power button (dropdown with logout, restart, shutdown)
# - second line of toggles/sliders:
#   - brightnes
#   - volume (icon toggles mute on/off, dropdown selects default output device)
# - large toggles with dropdowns for:
#   - wifi on/off (dropdown to select network)
#   - bluetooth on/off (dropdown to select device)
#   - do not disturb mode on/off (dropdown to set duration)
#   - theme light/dark (dropdown to select theme light/dark/auto)
#   - power saver mode on/off (dropdown to select profile)

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
