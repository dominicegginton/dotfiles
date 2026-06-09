{
  lib,
  runCommand,
  imagemagick,
  mkGnomeBackground,
  ...
}:

let
  # Solid build background image
  blueImage =
    runCommand "background.png"
      {
        nativeBuildInputs = [ imagemagick ];
        meta = {
          description = "Generated blue solid background";
          license = lib.licenses.free;
          platforms = lib.platforms.all;
          maintainers = with lib.maintainers; [ dominicegginton ];
        };
      }
      ''
        convert -size 3840x2160 \
          gradient:#4682B4-#4682B1 \
          $out
      '';
in
mkGnomeBackground {
  name = "background";
  src = blueImage;
  primaryColor = "#4682B4";
  secondaryColor = "#4682B1";
}
