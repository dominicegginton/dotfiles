{ lib, fetchurl, mkGnomeBackground, ... }:

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
