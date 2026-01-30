# features to be added:
# - appearance settings
#   - light / dark mode
#   - accent color
# - power settings
#   - screen blanking time
#   - suspend time
#   - power profile
# - network manager settings
#   - preferred wifi networks
# - bluetooth settings
#   - paired devices
#   - pairable devices
# - sound settings
#   - output volume per device
#   - input volume per device
#   - output device selection
#   - input device selection
# - display output settings
#   - resolution
#   - scaling
#   - refresh rate
#   - brightness
#   - multiple monitors configuration

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
}:

rustPlatform.buildRustPackage rec {
  name = "shell-settings";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    rustfmt
    pkg-config
    gcc
    glib
  ];
  buildInputs = [
    gtk4
    libadwaita
    cairo
  ];

  meta = with lib; {
    description = "Shell Settings";
    mainProgram = name;
    license = licenses.mit;
    maintainers = with maintainers; [ dominicegginton ];
    platforms = platforms.linux;
  };
}
