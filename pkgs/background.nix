{ lib, fetchurl }:

fetchurl rec {
  name = "a_colorful_swirls_of_paint.jpg";
  url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/abstract/a_colorful_swirls_of_paint.jpg";
  sha256 = "8ce0380d95f76c457eec19a2fae02756f38bc5a4ab6ea3de24ccb37124a254da";
  meta = {
    description = "Background image ${name} from ${url}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
