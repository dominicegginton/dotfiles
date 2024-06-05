{inputs}: let
  inherit
    (inputs)
    nixpkgs-unstable
    sops-nix
    nsm
    todo
    twm
    neovim-nightly
    ;

  defaultPackageFrom = module: attrs @ {system}:
    module.packages.${system}.default;
in {
  additions = final: _prev: let
    inherit (final) callPackage system;
  in {
    inherit
      (sops-nix.packages.${final.system})
      sops-import-keys-hook
      sops-init-gpg-key
      ;

    nsm = defaultPackageFrom nsm {inherit system;};
    todo = defaultPackageFrom todo {inherit system;};
    screensaver = callPackage ../pkgs/screensaver.nix {};
    git-sync = callPackage ../pkgs/git-sync.nix {};
    gpg-import-keys = callPackage ../pkgs/gpg-import-keys.nix {};
    twx = callPackage ../pkgs/twx.nix {};
    network-filters-disable = callPackage ../pkgs/network-filters-disable.nix {};
    network-filters-enable = callPackage ../pkgs/network-filters-enable.nix {};
    mmfm = callPackage ../pkgs/mmfm.nix {};
  };

  modifications = final: _prev: let
    inherit (final) system;
  in {
    twm = defaultPackageFrom twm {inherit system;};
    neovim = defaultPackageFrom neovim-nightly {inherit system;};
  };

  unstable-packages = final: _prev: let
    pkgs = import nixpkgs-unstable {
      inherit (final) system hostPlatform config;
    };
  in {
    unstable = pkgs;
  };
}
