{pkgs}: let
  inherit (pkgs) callPackage;
in {
  screensaver = callPackage ./screensaver.nix {};
  mmfm = callPackage ./mmfm.nix {};
  cleanup-trash = callPackage ./cleanup-trash.nix {};
  git-sync = callPackage ./git-sync.nix {};
  gpg-import-keys = callPackage ./gpg-import-keys.nix {};
  twx = callPackage ./twx.nix {};
  network-filters-disable = callPackage ./network-filters-disable.nix {};
  network-filters-enable = callPackage ./network-filters-enable.nix {};
}
