{ lib, stdenv, background, extract-theme, ... }:

stdenv.mkDerivation {
  name = "${background.name}-theme";
  src = background;
  dontUnpack = true;
  buildInputs = [ extract-theme ];
  buildPhase = ''
    extract-theme $src
  '';
  installPhase = ''
    mkdir -p $out
    mv theme.yaml $out/theme.yaml 
  '';
  meta = {
    description = "Theme extracted from ${background.name} using ${extract-theme.name}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
