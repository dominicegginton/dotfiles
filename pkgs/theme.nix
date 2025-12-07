{ lib, stdenv, background, extract-theme, ... }:

stdenv.mkDerivation rec {
  name = "residence-theme";
  src = background.backgroundImage;
  dontUnpack = true;
  buildInputs = [ extract-theme ];
  LOKY_MAX_CPU_COUNT = 1;
  THEME_FILE = "${name}.yaml";
  hash = lib.fakeHash;
  buildPhase = ''
    runHook preBuild
    extract-theme $src $THEME_FILE --colors 16
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mv $THEME_FILE $out
    runHook postInstall
  '';
  meta = {
    description = "Residence theme extracted from ${background.name} using ${extract-theme.name}";
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
    license = lib.licenses.free;
  };
}
