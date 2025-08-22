{ lib, stdenv, background, extract-theme, ... }:

stdenv.mkDerivation {
  name = "${background.name}-theme";
  dontUnpack = true;
  dontStrip = true;
  dontBuild = true;
  installPhase = ''
    ${lib.getExe extract-theme} ${background}
    mkdir -p $out
    mv theme.yaml $out/theme.yaml 
  '';
  meta = {
    description = "Theme extracted from ${background.name}}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  }
    }
