{ lib
, fetchurl
, stdenv
, imagemagick
, writeText
, runCommand
, ...
}:

let
  darken = src: runCommand "darkened-${src}" { nativeBuildInputs = [ imagemagick ]; } ''
    convert ${src} -fill black -colorize 70% -strip $out
  '';

  mkGnomeBackground =
    { src
    , srcDark ? (darken src)
    , name ? src.name
    , primaryColor ? "#333555"
    , secondaryColor ? "#555577"
    , description ? src.meta.description
    , license ? src.meta.license
    , ...
    }:

    let
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

      passthru = {
        inherit primaryColor secondaryColor;
        backgroundImage = src;
        darkBackgroundImage = srcDark;
        gnomeBackgroundXml = gnomeBackgroundXml;
      };

      meta = with lib; {
        inherit description license;
        maintainers = with maintainers; [ dominicegginton ];
        platforms = lib.platforms.all;
      };
    };
in

mkGnomeBackground {
  name = "a_painting_of_people_in_traditional_clothing";
  src = fetchurl rec {
    name = "a_painting_of_people_in_traditional_clothing";
    url = "https://github.com/dharmx/walls/blob/main/painting/a_painting_of_people_in_traditional_clothing.jpg?raw=true";
    sha256 = "01xrsiyrdpmgh8xjmhn0nzdwvw3s2q4h0rr9a64ks0nzmxhv9ad1";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
