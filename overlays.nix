{ inputs, lib }:

with lib;

let
  lib-packages = prev: final: lib // {
    development-promt = final.callPackage ./pkgs/development-promot.nix { };
  };
in

rec {
  additions = final: prev: {
    inherit (packagesFrom inputs.vulnix { inherit (final) system; }) vulnix;
    bootstrap-nixos-host = final.callPackage ./pkgs/bootstrap-nixos-host.nix { };
    bootstrap-nixos-installer = final.callPackage ./pkgs/bootstrap-nixos-installer.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    collect-garbage = final.callPackage ./pkgs/collect-garbage.nix { };
    export-aws-credentials = final.callPackage ./pkgs/export-aws-credentials.nix { };
    git-cleanup = final.callPackage ./pkgs/git-cleanup.nix { };
    git-sync = final.callPackage ./pkgs/git-sync.nix { };
    gpg-import-keys = final.callPackage ./pkgs/gpg-import-keys.nix { };
    install-nixos = final.callPackage ./pkgs/install-nixos.nix { };
    host-status = final.callPackage ./pkgs/host-status.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    nodejs-shell-setup-hook = final.callPackage ./pkgs/nodejs-shell-setup-hook.nix { };
    nixos-anywhere = final.callPackage (defaultPackageFrom inputs.nixos-anywhere) { };
    todo = final.callPackage (defaultPackageFrom inputs.todo) { };
    set-theme = final.callPackage ./pkgs/set-theme.nix { };
    twx = final.callPackage ./pkgs/twx.nix { };
    lib = prev.lib // lib // (lib-packages prev final);
  };

  modifications = final: prev: {
    twm = final.callPackage (defaultPackageFrom inputs.twm) { };
    neovim = final.callPackage (defaultPackageFrom inputs.neovim-nightly) { };
    lib = prev.lib // lib // (lib-packages prev final);
  };

  unstable-packages = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system hostPlatform config;
      overlays = [ additions modifications ];
    };
  };
}
