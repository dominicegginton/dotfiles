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
