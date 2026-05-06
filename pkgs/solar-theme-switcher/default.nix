{
  stdenv,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-solar-theme-switcher";
  version = "1.0.0";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp metadata.json extension.js $out/share/gnome-shell/extensions/${uuid}/
    runHook postInstall
  '';

  meta = {
    description = "Automatically switch between light and dark mode based on local sunrise and sunset times";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };

  uuid = "solar-theme-switcher@dominicegginton";

  passthru = {
    extensionUuid = uuid;
  };
}
