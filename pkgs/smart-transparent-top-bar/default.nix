{
  stdenv,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-smart-transparent-top-bar";
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
    description = "Makes the top bar transparent when no windows are touching it";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dominicegginton ];
  };

  uuid = "smart-transparent-top-bar@dominicegginton";

  passthru = {
    extensionUuid = uuid;
  };
}
