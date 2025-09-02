{ lib, fetchurl }:

fetchurl rec {
  name = "a_city_by_the_water.jpg";
  url = "https://images.unsplash.com/photo-1690996719621-5d880f8fb478?q=80&w=1454&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
  hash = "sha256-SKdpds9CJqNeehSplUrzImb58cpakJRW6KZtMnbpEEw=";
  meta = {
    description = "Background image ${name} from ${url}";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ dominicegginton ];
    platforms = lib.platforms.all;
  };
}
