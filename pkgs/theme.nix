{
  lib,
  stdenv,
  background,
  extract-theme,
  ...
}:

stdenv.mkDerivation rec {
  name = "residence-theme";

  # Use background image as source for theme extraction
  src = background.backgroundImage;
  dontUnpack = true;

  buildInputs = [ extract-theme ];

  # Limit CPU usage during theme extraction.
  LOKY_MAX_CPU_COUNT = 1;

  # Set output theme file name based on the package name.
  THEME_FILE = "${name}.yaml";

  # Use a fake hash since the output is deterministic and we don't want to
  # re-run the build if the source image changes (since it's a fixed input).
  hash = lib.fakeHash;

  # Extract colors from the background image
  buildPhase = ''
    runHook preBuild
    extract-theme $src $THEME_FILE --colors 16
    runHook postBuild
  '';

  # Install the generated theme YAML file
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mv $THEME_FILE $out
    runHook postInstall
  '';

  meta = {
    description = "Residence theme extracted from ${background.name} using ${extract-theme.name}";
    license = lib.licenses.free;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ dominicegginton ];
  };
}
