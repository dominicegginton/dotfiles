{ stdenv, ... }:

stdenv.mkDerivation rec {
  name = "network-filters";

  src = ./src;

  buildPhase = ''
    mkdir -p $out/bin
    cp $src/network-filters-enable.sh $out/bin
    cp $src/network-filters-disable.sh $out/bin
    chmod +x $out/bin/network-filters-enable.sh
    chmod +x $out/bin/network-filters-disable.sh
  '';
}
