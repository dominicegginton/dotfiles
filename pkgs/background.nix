{ lib, fetchurl, stdenv, imagemagick, writeText, ... }:

let

  mkBackground =
    { src
    , name ? src.name
    , description ? src.meta.description
    , license ? src.meta.license
    , ...
    }:

    let

      backgroundImageDark = stdenv.mkDerivation {
        inherit src;
        name = "${name}-dark";
        preferLocalBuild = true;
        dontUnpack = true;
        buildInputs = [ imagemagick ];
        buildPhase = ''
          runHook preBuild

          convert $src -fill black -colorize 70% -strip tmp.jpg

          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall

          mkdir -p $out
          mv tmp.jpg $out/$(basename ${src}).jpg

          runHook postInstall
        '';
        meta = with lib; {
          inherit (src.meta) license platforms;
          description = "Darkened version of ${src.name} for use as a dark background";
          maintainers = with maintainers; [ dominicegginton ];
        };
      };

      gnomeBackgroundXml = writeText "gnome-background-properties-${name}" '' 
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
        <wallpapers>
          <wallpaper deleted="false">
            <name>${name}</name>
            <filename>${src}</filename>
            <filename-dark>${backgroundImageDark}/$(basename ${src}).jpg</filename-dark>
            <options>zoom</options>
            <shade_type>solid</shade_type>
            <pcolor>#ffffff</pcolor>
            <scolor>#000000</scolor>
          </wallpaper>
        </wallpapers>
      '';

      background = stdenv.mkDerivation {
        inherit name;
        src = [ src backgroundImageDark ];
        dontUnpack = true;
        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/backgrounds/nixos
          mkdir -p $out/share/artwork/gnome
          mkdir -p $out/share/gnome-background-properties/
          ln -s ${src} $out/share/backgrounds/nixos/${src.name}
          ln -s ${backgroundImageDark}/$(basename ${src}).jpg $out/share/backgrounds/nixos/${src.name}.dark.jpg
          ln -s ${src} $out/share/artwork/gnome/${src.name}
          ln -s ${backgroundImageDark}/$(basename ${src}).jpg $out/share/artwork/gnome/${src.name}.dark.jpg
          ln -s ${gnomeBackgroundXml} $out/share/gnome-background-properties/${name}.xml

          runHook postInstall
        '';

        meta = with lib; {
          inherit description license;
          maintainers = with maintainers; [ dominicegginton ];
          platforms = lib.platforms.all;
        };
      };
    in

    background;
in

mkBackground {
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
