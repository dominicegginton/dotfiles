{pkgs ? (import ../nixpkgs.nix) {}}: let
  inherit (pkgs) callPackage;
in {
  # node packages
  my.nodePackages.custom-elements-languageserver = callPackage ./node-packages/custom-elements-languageserver.nix {};
  gpg-import-keys = callPackage ./gpg/import-keys.nix {};
  network-filters-enable = callPackage ./network-filters/enable.nix {};
  network-filters-disable = callPackage ./network-filters/disable.nix {};
  rebuild-home = callPackage ./rebuild/home.nix {};
  rebuild-host = callPackage ./rebuild/host.nix {};
  rebuild-iso-console = callPackage ./rebuild/iso-console.nix {};
}
