{ inputs, lib }:

with lib;

rec {
  additions = final: prev: {
    inherit (packagesFrom inputs.sops-nix { inherit (final) system; }) sops-import-keys-hook sops-init-gpg-key;
    inherit (packagesFrom inputs.nixos-images { inherit (final) system; }) image-installer-nixos-stable;
    todo = final.callPackage (defaultPackageFrom inputs.todo) { };
    bootstrap-nixos-iso-device = final.callPackage ./pkgs/bootstrap-nixos-iso-device.nix { };
    collect-garbage = final.callPackage ./pkgs/collect-garbage.nix { };
    export-aws-credentials = final.callPackage ./pkgs/export-aws-credentials.nix { };
    gpg-import-keys = final.callPackage ./pkgs/gpg-import-keys.nix { };
    install-nixos = final.callPackage ./pkgs/install-nixos.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    nodejs-shell-setup-hook = final.callPackage ./pkgs/nodejs-shell-setup-hook.nix { };
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
