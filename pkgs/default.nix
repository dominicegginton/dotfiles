{pkgs}: let
  inherit (pkgs) callPackage;
in {
  # configuration utils
  workspace.rebuild-host = callPackage ./rebuild-host.nix {};
  workspace.rebuild-home = callPackage ./rebuild-home.nix {};
  workspace.rebuild-configuration = callPackage ./rebuild-configuration.nix {};
  workspace.upgrade-configuration = callPackage ./upgrade-configuration.nix {};
  workspace.format-configuration = callPackage ./format-configuration.nix {};
  # iso utils
  workspace.create-iso-usb = callPackage ./create-iso-usb.nix {};
  workspace.rebuild-iso-console = callPackage ./rebuild-iso-console.nix {};
  # host utils
  workspace.shutdown-host = callPackage ./shutdown-host.nix {};
  workspace.reboot-host = callPackage ./reboot-host.nix {};
  # user utils
  workspace.git-sync = callPackage ./git-sync.nix {};
  workspace.gpg-import-keys = callPackage ./gpg-import-keys.nix {};
  workspace.twx = callPackage ./twx.nix {};
  # network utils
  workspace.network-filters-disable = callPackage ./network-filters-disable.nix {};
  workspace.network-filters-enable = callPackage ./network-filters-enable.nix {};
  # node packages
  workspace.nodePackages.custom-elements-languageserver = callPackage ./node-packages/custom-elements-languageserver.nix {};
}
