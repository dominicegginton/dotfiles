# Features to be implemented:
# - Appearance: Light/dark mode, accent colors
# - Power: Screen blanking, suspend times, profiles
# - Connectivity: WiFi and Bluetooth device management
# - Audio: Volume and device selection per input/output
# - Display: Resolution, scaling, refresh rate, brightness

{
  lib,
  makeDesktopItem,
  rustPlatform,
  rustfmt,
  pkg-config,
  gcc,
  glib,
  gtk4,
  libadwaita,
  cairo,
}:

let
  # Build the shell-settings application
  pkg = rustPlatform.buildRustPackage rec {
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
  };

  desktopFile = makeDesktopItem rec {
    name = "dev.dominicegginton.${pkg.name}";
    desktopName = pkg.name;
    comment = pkg.meta.description;
    exec = lib.getExe pkg;
    icon = name;
    categories = [ "Utility" ];
  };

  desktopIcon = ./src/icon.svg;

in
pkg.overrideAttrs (_: {
  postInstall = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/scalable/apps

    cp ${desktopFile}/share/applications/dev.dominicegginton.${pkg.name}.desktop $out/share/applications/dev.dominicegginton.${pkg.name}.desktop
    cp ${desktopIcon} $out/share/icons/hicolor/scalable/apps/dev.dominicegginton.${pkg.name}.svg

  '';
})
