{ inputs }:
let
  defaultPackageFrom = module: attrs @ { system }:
    module.packages.${system}.default;
in
{
  additions = final: _prev:
    let
      inherit (final) callPackage system;
    in
    {
      inherit
        (inputs.sops-nix.packages.${system})
        sops-import-keys-hook
        sops-init-gpg-key
        ;

      nsm = defaultPackageFrom inputs.nsm { inherit system; };
      todo = defaultPackageFrom inputs.todo { inherit system; };
      screensaver = callPackage ./pkgs/screensaver.nix { };
      git-sync = callPackage ./pkgs/git-sync.nix { };
      gpg-import-keys = callPackage ./pkgs/gpg-import-keys.nix { };
      twx = callPackage ./pkgs/twx.nix { };
      network-filters-disable = callPackage ./pkgs/network-filters-disable.nix { };
      network-filters-enable = callPackage ./pkgs/network-filters-enable.nix { };
      mmfm = callPackage ./pkgs/mmfm.nix { };
      collect-garbage = callPackage ./pkgs/collect-garbage.nix { };
    };

  modifications = final: _prev:
    let
      inherit (final) system;
    in
    {
      twm = defaultPackageFrom inputs.twm { inherit system; };
      neovim = defaultPackageFrom inputs.neovim-nightly { inherit system; };
    };

  unstable-packages = final: _prev:
    let
      pkgs = import inputs.nixpkgs-unstable {
        inherit (final) system hostPlatform config;
      };
    in
    {
      unstable = pkgs;
    };
}
