{inputs}: {
  additions = final: _prev: let
    inherit (final) callPackage;
  in {
    inherit
      (inputs.sops-nix.packages.${final.system})
      sops-import-keys-hook
      sops-init-gpg-key
      ;
    nsm = inputs.nsm.packages.${final.system}.default;
    todo = inputs.todo.packages.${final.system}.default;
    screensaver = callPackage ../pkgs/screensaver.nix {};
    cleanup-trash = callPackage ../pkgs/cleanup-trash.nix {};
    git-sync = callPackage ../pkgs/git-sync.nix {};
    gpg-import-keys = callPackage ../pkgs/gpg-import-keys.nix {};
    twx = callPackage ../pkgs/twx.nix {};
    network-filters-disable = callPackage ../pkgs/network-filters-disable.nix {};
    network-filters-enable = callPackage ../pkgs/network-filters-enable.nix {};
    mmfm = callPackage ../pkgs/mmfm.nix {};
  };
  modifications = final: _prev: {
    twm = inputs.twm.packages.${final.system}.default;
    neovim = inputs.neovim-nightly.packages.${final.system}.neovim;
  };
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system hostPlatform config;
    };
  };
}
