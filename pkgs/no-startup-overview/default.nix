{ stdenv
, lib
,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-no-startup-overview";
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
    description = "Disable the GNOME Shell overview at startup";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dominicegginton ];
  };

  uuid = "no-startup-overview@dominicegginton";

  passthru = {
    extensionUuid = uuid;
  };
}
