{
  stdenv,
  lib,
  glib,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-intelli";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [
    glib
  ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas --strict schemas
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r metadata.json extension.js stylesheet.css schemas $out/share/gnome-shell/extensions/${uuid}/

    # Install schema to global schemas dir for GSettings
    mkdir -p $out/share/glib-2.0/schemas
    cp schemas/org.gnome.shell.extensions.intelli.gschema.xml $out/share/glib-2.0/schemas/
    runHook postInstall
  '';

  meta = {
    description = "A simple intelli extension with a text box";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dominicegginton ];
  };

  uuid = "intelli@dominicegginton";

  passthru = {
    extensionUuid = uuid;
  };
}
