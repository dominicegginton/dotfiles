{ inputs, lib }:

with lib;

rec {
  additions = final: prev: {
    inherit (packagesFrom inputs.nixos-images { inherit (final) system; }) image-installer-nixos-stable;
    inherit (packagesFrom inputs.vulnix { inherit (final) system; }) vulnix;
    bootstrap-nixos-host = final.callPackage ./pkgs/bootstrap-nixos-host.nix { };
    bootstrap-nixos-iso-device = final.callPackage ./pkgs/bootstrap-nixos-iso-device.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    collect-garbage = final.callPackage ./pkgs/collect-garbage.nix { };
    export-aws-credentials = final.callPackage ./pkgs/export-aws-credentials.nix { };
    gpg-import-keys = final.callPackage ./pkgs/gpg-import-keys.nix { };
    install-nixos = final.callPackage ./pkgs/install-nixos.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    nodejs-shell-setup-hook = final.callPackage ./pkgs/nodejs-shell-setup-hook.nix { };
    nixos-anywhere = final.callPackage (defaultPackageFrom inputs.nixos-anywhere) { };
    todo = final.callPackage (defaultPackageFrom inputs.todo) { };
    secrets-sync = final.callPackage ./pkgs/secrets-sync.nix { };
    twx = final.callPackage ./pkgs/twx.nix { };
    lib = prev.lib // lib;
  };

  modifications = final: prev: {
    twm = final.callPackage (defaultPackageFrom inputs.twm) { };
    neovim = final.callPackage (defaultPackageFrom inputs.neovim-nightly) { };
    lib = prev.lib // lib;
  };

  unstable-packages = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system hostPlatform config;
      overlays = [ additions modifications ];
    };
  };
}
