{ pkgs ? (import ../nixpkgs.nix) { } }:

{
  gpg-import-keys = pkgs.callPackage ./gpg/import-keys.nix { };
  network-filters-enable = pkgs.callPackage ./network-filters/enable.nix { };
  network-filters-disable = pkgs.callPackage ./network-filters/disable.nix { };
}
