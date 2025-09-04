{ lib, stdenv, background, extract-theme, ... }:

stdenv.mkDerivation rec {
  name = "residence-theme";
  src = background;
  dontUnpack = true;
  buildInputs = [ extract-theme ];
  LOKY_MAX_CPU_COUNT = 1;
  THEME_FILE = "${name}.yaml";
  hash = lib.fakeHash;
  buildPhase = ''
    extract-theme $src $THEME_FILE --colors 16 
  '';
  installPhase = ''
    mkdir -p $out
    mv $THEME_FILE $out
  '';
  meta = {
    description = "Residence theme extracted from ${background.name} using ${extract-theme.name}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
