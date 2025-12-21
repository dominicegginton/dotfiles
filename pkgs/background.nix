{ lib, fetchurl, mkGnomeBackground, ... }:

mkGnomeBackground {
  name = "green-trees-near-body-of-water-during-daytime";
  src = fetchurl rec {
    name = "green-trees-near-body-of-water-during-daytime.jpg";
    url = "https://images.unsplash.com/photo-1597157153515-028fa3d4bd69?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb&dl=eric-lee-ss8Dka_Tvwg-unsplash.jpg";
    sha256 = "sha256-O/RE/82J9t0vgsrNBofTYd8qjflYeCqjeEvyGshec9E=";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
