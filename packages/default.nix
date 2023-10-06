final: prev: {
  my = {
    theme-switcher = final.callPackage ./theme-switcher.nix {};
    network-filters = final.callPackage ./network-filters.nix {};
  };
}
