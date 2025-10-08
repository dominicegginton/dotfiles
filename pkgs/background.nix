{ lib, fetchurl, stdenv, imagemagick, ... }:
let

  mkBackground = { name, src, description, license ? lib.licenses.free, ... }:
    let
      darkSrc = stdenv.mkDerivation {
        name = "darkened-image";
        inherit src;
        dontUnpack = true;
        buildInputs = [ imagemagick ];
        buildPhase = ''
          runHook preBuild
          convert $src -modulate 70,0,100 -fill black -colorize 30% $src.dark.jpg
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          mv $src.dark.jpg $out/
          runHook postInstall
        '';
        meta = with lib; {
          description = "Darkened version of ${src}";
          maintainers = with maintainers; [ dominicegginton ];
          license = lib.licenses.free;
          platforms = platforms.all;
        };
      };
      pkg = stdenv.mkDerivation {
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
              <filename-dark>${darkSrc}/$(basename ${src}).dark.jpg</filename-dark>
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
          filePath = "${pkg}/share/backgrounds/nixos/${src.name}";
          gnomeFilePath = "${pkg}/share/backgrounds/nixos/${src.name}";
          kdeFilePath = "${pkg}/share/wallpapers/${name}/contents/images/${src.name}";
        };
        meta = with lib; {
          inherit description license;
          maintainers = with maintainers; [ dominicegginton ];
          platforms = platforms.all;
        };
      };
    in
    pkg;
in
mkBackground {
  name = "a_castle_on_a_hill_with_fog_with_Eltz_Castle_in_the_background";
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
  description = "A castle on a hill with fog with Eltz Castle in the background";
  license = lib.licenses.free;
}
