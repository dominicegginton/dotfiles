{pkgs ? (import ../nixpkgs.nix) {}}: let
  inherit (pkgs) callPackage;
in {
  # system utils
  rebuild-host = callPackage ./rebuild-host.nix {};
  rebuild-iso-console = callPackage ./rebuild-iso-console.nix {};
  # user utils
  rebuild-home = callPackage ./rebuild-home.nix {};
  gpg-import-keys = callPackage ./gpg-import-keys.nix {};
  # network utils
  network-filters-disable = callPackage ./network-filters-disable.nix {};
  network-filters-enable = callPackage ./network-filters-enable.nix {};
  # node packages
  my.nodePackages.custom-elements-languageserver = callPackage ./node-packages/custom-elements-languageserver.nix {};
}
