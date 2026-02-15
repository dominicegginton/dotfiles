{
  lib,
  fetchurl,
  mkGnomeBackground,
  ...
}:

mkGnomeBackground {
  name = "background";
  src = fetchurl rec {
    name = "background.jpg";
    url = "https://images.unsplash.com/photo-1497436072909-60f360e1d4b1?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb&dl=andreas-gucklhorn-mawU2PoJWfU-unsplash.jpg";
    sha256 = "sha256-6uqftKcWMiU81t9wiIF/2v9+VXJWBhOA9NVaQF/SD/8=";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
