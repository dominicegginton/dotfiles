{ inputs, lib }:

with lib;

rec {
  default = final: prev: {
    inherit (packagesFrom inputs.vulnix { inherit (final) system; }) vulnix;
    flip = final.callPackage (defaultPackageFrom inputs.flip) { };
    neovim = final.callPackage (defaultPackageFrom inputs.neovim-nightly) { };
    nixos-anywhere = final.callPackage (defaultPackageFrom inputs.nixos-anywhere) { };
    todo = final.callPackage (defaultPackageFrom inputs.todo) { };
    roll = final.callPackage (defaultPackageFrom inputs.roll) { };
    twm = final.callPackage (defaultPackageFrom inputs.twm) { };
    bootstrap-nixos-host = final.callPackage ./pkgs/bootstrap-nixos-host.nix { };
    bootstrap-nixos-installer = final.callPackage ./pkgs/bootstrap-nixos-installer.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    collect-garbage = final.callPackage ./pkgs/collect-garbage.nix { };
    git-cleanup = final.callPackage ./pkgs/git-cleanup.nix { };
    git-sync = final.callPackage ./pkgs/git-sync.nix { };
    gpg-import-keys = final.callPackage ./pkgs/gpg-import-keys.nix { };
    install-nixos = final.callPackage ./pkgs/install-nixos.nix { };
    host-status = final.callPackage ./pkgs/host-status.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    set-prompt-shell-hook = final.callPackage ./pkgs/set-prompt-shell-hook.nix { };
    set-theme = final.callPackage ./pkgs/set-theme.nix { };
    twx = final.callPackage ./pkgs/twx.nix { };
    source-nodejs-packages-shell-hook = final.callPackage ./pkgs/source-nodejs-packages-shell-hook.nix { };
    mkShell =
      { inputsFrom ? null
      , name ? if inputsFrom != null
        then (builtins.concatStringsSep " " (builtins.map (pkg: pkg.name) inputsFrom))
        else "ad-hoc"
      , ...
      } @args:
      prev.mkShell (args // {
        nativeBuildInputs = [ (final.set-prompt-shell-hook name) ] ++ (args.nativeBuildInputs or [ ]);
      });
    lib = prev.lib // lib;
  };

  unstable = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system hostPlatform config;
      overlays = [ default ];
    };
  };
}
