{ lib, fetchurl, stdenv, imagemagick, ... }:

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
          description = "Darkened version of ${backgroundImage}";
          maintainers = with maintainers; [ dominicegginton ];
        };
      };

      background = stdenv.mkDerivation {
        inherit name;
        src = [ src backgroundImageDark ];
        dontUnpack = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/backgrounds/nixos
          ln -s ${src} $out/share/backgrounds/nixos/${src.name}
          mkdir -p $out/share/gnome-background-properties/
          cat <<EOF > $out/share/gnome-background-properties/${name}.xml
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
          EOF
          mkdir -p $out/share/artwork/gnome
          ln -s ${src} $out/share/artwork/gnome/${src.name}
          mkdir -p $out/share/wallpapers/${name}/contents/images
          ln -s ${src} $out/share/wallpapers/${name}/contents/images/${src.name}
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
  name = "photo-1726992118416-00c2fa03e03b";
  src = fetchurl rec {
    name = "photo-1726992118416-00c2fa03e03b";
    url = "https://images.unsplash.com/photo-1726992118416-00c2fa03e03b";
    sha256 = "0mrc71l7rnz5rnqrgls9d7gv36z8hx2lamzrg8dwa143i1mpr45k";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
