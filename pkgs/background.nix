{ lib, fetchurl }:

fetchurl rec {
  name = "1398452.jpg";
  url = "https://images6.alphacoders.com/139/1398452.jpg";
  hash = "sha256-U1KOW31Rn66mwxMlpAlDArrMyvCi+ILEQBqmfdRnlro=";
  meta = {
    description = "Background image ${name} from ${url}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
