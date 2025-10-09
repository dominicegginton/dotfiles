{ lib, fetchurl, stdenv, imagemagick, ... }:

let

  mkBackground = { name, src, description, license ? lib.licenses.free, ... }:

    let

      backgroundImageDark = stdenv.mkDerivation {
        inherit src;
        name = "darkened-image";
        dontUnpack = true;
        buildInputs = [ imagemagick ];
        buildPhase = ''
          runHook preBuild
          convert $src -fill black -colorize 30% $backgroundImage.dark.jpg 
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          mv $backgroundImage.dark.jpg $out/$(basename ${src}).dark.jpg
          runHook postInstall
        '';
        meta = with lib; {
          description = "Darkened version of ${backgroundImage}";
          maintainers = with maintainers; [ dominicegginton ];
          platforms = imagemagick.meta.platforms;
        };
      };

      background = stdenv.mkDerivation {
        inherit name src;
        dontUnpack = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/backgrounds/nixos
          ln -s $src $out/share/backgrounds/nixos/${src.name}
          mkdir -p $out/share/gnome-background-properties/
          cat <<EOF > $out/share/gnome-background-properties/${name}.xml
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
          <wallpapers>
            <wallpaper deleted="false">
              <name>${name}</name>
              <filename>${src}</filename>
              <filename-dark>${backgroundImageDark}/$(basename ${src}).dark.jpg</filename-dark>
              <options>zoom</options>
              <shade_type>solid</shade_type>
              <pcolor>#ffffff</pcolor>
              <scolor>#000000</scolor>
            </wallpaper>
          </wallpapers>
          EOF
          mkdir -p $out/share/artwork/gnome
          ln -s $src $out/share/artwork/gnome/${src.name}
          mkdir -p $out/share/wallpapers/${name}/contents/images
          ln -s $src $out/share/wallpapers/${name}/contents/images/${src.name}
          cat >>$out/share/wallpapers/${name}/metadata.desktop <<_EOF
          [Desktop Entry]
          Name=${name}
          X-KDE-PluginInfo-Name=${name}
          _EOF
          runHook postInstall
        '';
        passthru = {
          light = "${src}/$(basename ${src})";
          dark = "${backgroundImageDark}/$(basename ${src}).dark.jpg";
          filePath = "${background}/share/backgrounds/nixos/${src.name}";
          gnomeFilePath = "${background}/share/backgrounds/nixos/${src.name}";
          kdeFilePath = "${background}/share/wallpapers/${name}/contents/images/${src.name}";
        };
        meta = with lib; {
          inherit description license;
          maintainers = with maintainers; [ dominicegginton ];
          platforms = src.meta.platforms ++ imagemagick.meta.platforms;
        };
      };

    in

    background;
in

mkBackground {
  name = "a_castle_on_a_hill_with_fog_with_Eltz_Castle_in_the_background";
  description = "A castle on a hill with fog with Eltz Castle in the background";
  src = fetchurl rec {
    name = "a_castle_on_a_hill_with_fog_with_Eltz_Castle_in_the_background.jpg";
    url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/mountain/a_castle_on_a_hill_with_fog_with_Eltz_Castle_in_the_background.jpg";
    sha256 = "0l59xwjs9xlz2mxq9v73gcmw7h3jjqnxgy24c5karm7ysbgwb41q";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
