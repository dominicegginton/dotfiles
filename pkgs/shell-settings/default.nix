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
  makeDesktopItem,
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

let
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
