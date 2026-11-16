{ stdenv
, lib
,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-frosted-background-focus";
  version = "1.0.0";
  src = ./.;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp metadata.json extension.js $out/share/gnome-shell/extensions/${uuid}/
    runHook postInstall
  '';

  uuid = "frosted-background-focus@dominicegginton";

  passthru.extensionUuid = uuid;

  meta = {
    description = "Blur all screen content except the focused window in GNOME Shell";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dominicegginton ];
  };
}
