final: prev: {
  my = {
    network-filters = final.callPackage ./network-filters.nix {};
  };
}
