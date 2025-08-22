{ lib, fetchurl }:

fetchurl rec {
  name = "a_city_by_the_water.jpg";
  url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/architecture/a_city_by_the_water.jpg";
  hash = "sha256-/ANSbbf9vmQaVtN7w4nNW0v/9b5Nh61agL+v+Nqqjm4=";
  meta = {
    description = "Background image ${name} from ${url}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
