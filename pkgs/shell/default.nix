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
