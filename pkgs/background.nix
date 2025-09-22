{ lib, fetchurl }:

fetchurl rec {
  name = "a_castle_on_a_hill_with_fog_with_Eltz_Castle_in_the_background.jpg";
  url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/mountain/a_castle_on_a_hill_with_fog_with_Eltz_Castle_in_the_background.jpg";
  sha256 = "0l59xwjs9xlz2mxq9v73gcmw7h3jjqnxgy24c5karm7ysbgwb41q";
  meta = {
    description = "Background image ${name} from ${url}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
