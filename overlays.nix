{ inputs, myLib }:

let
  inherit (inputs)
    nixpkgs-unstable
    sops-nix
    nsm
    todo
    twm
    neovim-nightly;
in

with myLib;

{
  additions = final: prev:

    let
      inherit (final) callPackage;
    in

    {
      inherit
        (packagesFrom sops-nix { inherit (final) system; })
        sops-import-keys-hook
        sops-init-gpg-key
        ;

      nsm = callPackage (defaultPackageFrom nsm) { };
      todo = callPackage (defaultPackageFrom todo) { };
      git-sync = callPackage ./pkgs/git-sync.nix { };
      gpg-import-keys = callPackage ./pkgs/gpg-import-keys.nix { };
      twx = callPackage ./pkgs/twx.nix { };
      network-filters-disable = callPackage ./pkgs/network-filters-disable.nix { };
      network-filters-enable = callPackage ./pkgs/network-filters-enable.nix { };
      mmfm = callPackage ./pkgs/mmfm.nix { };
      collect-garbage = callPackage ./pkgs/collect-garbage.nix { };
    };

  modifications = final: prev:

    let
      inherit (final) callPackage;
    in

    {
      twm = callPackage (defaultPackageFrom twm) { };
      neovim = callPackage (defaultPackageFrom neovim-nightly) { };
    };

  unstable-packages = final: _prev: {
    unstable = import nixpkgs-unstable {
      inherit (final) system hostPlatform config;
    };
  };
}
