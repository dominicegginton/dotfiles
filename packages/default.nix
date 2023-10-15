final: prev: {
  my = {
    gpg-keys-utils = final.callPackage ./gpg-keys-utils.nix {};
    network-filters = final.callPackage ./network-filters {};
  };
}
