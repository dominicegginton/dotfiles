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
  name = "AAAABXy27SOJ7bh3yO_zA1t9flg-s8m_0J4F2oL4GqdnfdnNLOu0PwaDHZKXXe9euvWl7nAut9Rt67WWc01EOiCCpFusYoDTyL2kd60S.jpg";
  src = fetchurl rec {
    name = "AAAABXy27SOJ7bh3yO_zA1t9flg-s8m_0J4F2oL4GqdnfdnNLOu0PwaDHZKXXe9euvWl7nAut9Rt67WWc01EOiCCpFusYoDTyL2kd60S.jpg";
    url = "https://occ-0-8407-2219.1.nflxso.net/dnm/api/v6/6AYY37jfdO6hpXcMjf9Yu5cnmO0/AAAABXy27SOJ7bh3yO_zA1t9flg-s8m_0J4F2oL4GqdnfdnNLOu0PwaDHZKXXe9euvWl7nAut9Rt67WWc01EOiCCpFusYoDTyL2kd60S.jpg";
    sha256 = "1w218p6i5pi86ckfdh73inwj3rrvk0fp7vkpp2pqjyzjp3h9kv7j";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
