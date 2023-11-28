{pkgs ? (import ../nixpkgs.nix) {}}: let
  inherit (pkgs) callPackage;
in {
  # host utils
  workspace.create-iso-usb = callPackage ./create-iso-usb.nix {};
  workspace.rebuild-host = callPackage ./rebuild-host.nix {};
  workspace.rebuild-iso-console = callPackage ./rebuild-iso-console.nix {};
  workspace.shutdown-host = callPackage ./shutdown-host.nix {};
  # user utils
  workspace.rebuild-home = callPackage ./rebuild-home.nix {};
  workspace.gpg-import-keys = callPackage ./gpg-import-keys.nix {};
  # network utils
  workspace.network-filters-disable = callPackage ./network-filters-disable.nix {};
  workspace.network-filters-enable = callPackage ./network-filters-enable.nix {};
  # node packages
  workspace.nodePackages.custom-elements-languageserver = callPackage ./node-packages/custom-elements-languageserver.nix {};
}
