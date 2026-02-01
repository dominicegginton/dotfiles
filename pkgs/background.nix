{
  lib,
  fetchurl,
  mkGnomeBackground,
  ...
}:

mkGnomeBackground {
  name = "background";
  src = fetchurl rec {
    name = "marlene-celine-nordvik-65_sFYsNXtg-unsplash.jpg";
    url = "https://images.unsplash.com/photo-1553902001-149de4c1bd99?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb&dl=marlene-celine-nordvik-65_sFYsNXtg-unsplash.jpg";
    sha256 = "sha256-lcD4p2e77pR/SMmrFbwJvNO9bc2meq/N/cEQhOq2/9Q=";
    meta = {
      description = "Background image ${name} from ${url}";
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [ dominicegginton ];
      platforms = lib.platforms.all;
    };
  };
}
