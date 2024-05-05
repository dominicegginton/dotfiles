{inputs}: {
  additions = final: _prev: let
    inherit (final) callPackage;
  in {
    nsm = inputs.nsm.packages.${final.system}.default;
    todo = inputs.todo.packages.${final.system}.todo;
    screensaver = callPackage ../pkgs/screensaver.nix {};
    cleanup-trash = callPackage ../pkgs/cleanup-trash.nix {};
    git-sync = callPackage ../pkgs/git-sync.nix {};
    gpg-import-keys = callPackage ../pkgs/gpg-import-keys.nix {};
    twx = callPackage ../pkgs/twx.nix {};
    network-filters-disable = callPackage ../pkgs/network-filters-disable.nix {};
    network-filters-enable = callPackage ../pkgs/network-filters-enable.nix {};
  };
  modifications = final: _prev: let
    inherit (final) callPackage;
  in {
    mmfm = callPackage ../pkgs/mmfm.nix {};
  };
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {inherit (final) system;};
  };
}
