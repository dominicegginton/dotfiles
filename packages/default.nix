final: prev: {
  my = {
    gpg-import-keys = final.callPackage ./gpg/import-keys.nix {};
    network-filters-enable = final.callPackage ./network-filters/enable.nix {};
    network-filters-disable = final.callPackage ./network-filters/disable.nix {};
  };
}
