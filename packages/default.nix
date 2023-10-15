final: prev: {
  my = {
    gpg-keys-utils = final.callPackage ./gpg-keys-utils.nix {};
    network-filters-enable = final.callPackage ./network-filters/enable.nix {};
    network-filters-disable = final.callPackage ./network-filters/disable.nix {};
  };
}
