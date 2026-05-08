{
  stdenv,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-light-theme-default";
  version = "1.0.0";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp metadata.json extension.js stylesheet.css $out/share/gnome-shell/extensions/${uuid}/
    runHook postInstall
  '';

  meta = {
    description = "Forces GNOME Shell to use the light theme while enabled";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dominicegginton ];
  };

  uuid = "light-theme-default@dominicegginton";

  passthru = {
    extensionUuid = uuid;
  };
}
