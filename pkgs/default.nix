{pkgs}: let
  inherit (pkgs) callPackage;
in {
  rebuild-host = callPackage ./rebuild-host.nix {};
  rebuild-home = callPackage ./rebuild-home.nix {};
  rebuild-configuration = callPackage ./rebuild-configuration.nix {};
  upgrade-configuration = callPackage ./upgrade-configuration.nix {};
  create-iso-usb = callPackage ./create-iso-usb.nix {};
  rebuild-iso-console = callPackage ./rebuild-iso-console.nix {};
  cleanup-trash = callPackage ./cleanup-trash.nix {};
  shutdown-host = callPackage ./shutdown-host.nix {};
  reboot-host = callPackage ./reboot-host.nix {};
  suspend-host = callPackage ./suspend-host.nix {};
  hibernate-host = callPackage ./hibernate-host.nix {};
  git-sync = callPackage ./git-sync.nix {};
  gpg-import-keys = callPackage ./gpg-import-keys.nix {};
  twx = callPackage ./twx.nix {};
  network-filters-disable = callPackage ./network-filters-disable.nix {};
  network-filters-enable = callPackage ./network-filters-enable.nix {};
}
