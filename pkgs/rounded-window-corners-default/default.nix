{
  stdenv,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-rounded-window-corners-default";
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
    description = "Rounds window decoration corners to the default GNOME radius (12px)";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };

  uuid = "rounded-window-corners-default@dominicegginton";

  passthru = {
    extensionUuid = uuid;
  };
}
