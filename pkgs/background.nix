{ lib, fetchurl, mkGnomeBackground, ... }:

mkGnomeBackground {
  name = "a_snow_covered_houses_and_a_street_light";
  src = fetchurl rec {
    name = "a_snow_covered_houses_and_a_street_light.png";
    url = "https://github.com/dharmx/walls/blob/main/cold/a_snow_covered_houses_and_a_street_light.png?raw=true";
    sha256 = "sha256-7rzLoY0Bh6xUfn7cVsNpBJnJ4/vVdwCRK5afziEnlWk=";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
