{pkgs ? (import ../nixpkgs.nix) {}}: {
  gpg-import-keys = pkgs.callPackage ./gpg/import-keys.nix {};
  network-filters-enable = pkgs.callPackage ./network-filters/enable.nix {};
  network-filters-disable = pkgs.callPackage ./network-filters/disable.nix {};
  rebuild-darwin = pkgs.callPackage ./rebuild/darwin.nix {};
  rebuild-home = pkgs.callPackage ./rebuild/home.nix {};
  rebuild-host = pkgs.callPackage ./rebuild/host.nix {};
  rebuild-iso-console = pkgs.callPackage ./rebuild/iso-console.nix {};
}
