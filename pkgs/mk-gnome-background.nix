# mk-gnome-background is a helper function to create a GNOME background package
# from a source image. It automatically generates a darkened version of the image
# if one is not provided and creates the necessary GNOME background XML properties.
{
  lib,
  stdenv,
  imagemagick,
  writeText,
  runCommand,
  ...
}:

let
  # darken is a helper function that uses imagemagick to darken an image
  darken =
    src:
    runCommand "darkened-${src}" { nativeBuildInputs = [ imagemagick ]; } ''
      convert ${src} -fill black -colorize 70% -strip $out
    '';
in
{
  # The source image for the background
  src,
  # The dark version of the source image, defaults to a darkened version of src
  srcDark ? (darken src),
  # The name of the background package
  name ? src.name,
  # Primary and secondary colors for the background properties
  primaryColor ? "#333555",
  secondaryColor ? "#555577",
  # Metadata descriptions and licenses
  description ? src.meta.description,
  license ? src.meta.license,
  ...
}:

let
  # gnomeBackgroundXml generates the XML configuration required by GNOME to recognize the wallpaper
  gnomeBackgroundXml = writeText "gnome-background-properties-${name}" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
    <wallpapers>
      <wallpaper deleted="false">
      <name>${name}</name>
      <filename>${src}</filename>
      <filename-dark>${srcDark}</filename-dark>
      <options>zoom</options>
      <shade_type>solid</shade_type>
      <pcolor>${primaryColor}</pcolor>
      <scolor>${secondaryColor}</scolor>
    </wallpaper>
    </wallpapers>
  '';
in

stdenv.mkDerivation {
  inherit name;
  dontUnpack = true;

  # Install the background images and the XML properties file into the appropriate directories
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/backgrounds/nixos
    mkdir -p $out/share/artwork/gnome
    mkdir -p $out/share/gnome-background-properties/
    ln -s ${src} $out/share/backgrounds/nixos/${src.name}
    ln -s ${srcDark} $out/share/backgrounds/nixos/darkened-${src.name}
    ln -s ${src} $out/share/artwork/gnome/${src.name}
    ln -s ${srcDark} $out/share/artwork/gnome/darkened-${src.name}
    ln -s ${gnomeBackgroundXml} $out/share/gnome-background-properties/${name}.xml

    runHook postInstall
  '';

  # Export useful attributes for other modules to consume
  passthru = {
    inherit primaryColor secondaryColor;
    backgroundImage = src;
    darkBackgroundImage = srcDark;
    gnomeBackgroundXml = gnomeBackgroundXml;
  };

  meta = with lib; {
    inherit description license;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dominicegginton ];
  };
}
