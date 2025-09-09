{ lib, fetchurl }:

fetchurl rec {
  name = "h0lBtpi.jpeg";
  url = "https://i.imgur.com/h0lBtpi.jpeg";
  sha256 = "1nfh9fk69gjyjlshhxpnbysa3969gcskl70rl29dh3g27224zw6z";
  meta = {
    description = "Background image ${name} from ${url}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
