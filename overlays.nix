{ inputs, lib }:

let
  inherit (inputs)
    nixpkgs-unstable
    sops-nix
    nsm
    todo
    twm
    neovim-nightly;
in

with lib;

{
  default = final: prev: {
    inherit
      (packagesFrom sops-nix { inherit (final) system; })
      sops-import-keys-hook
      sops-init-gpg-key;
    lib = prev.lib // lib;
  };

  additions = final: prev: {
    ## temp
    install-nixos = final.callPackage ./pkgs/install-nixos.nix { };
    bootstrap-nixos-iso-device = final.callPackage ./pkgs/bootstrap-nixos-iso-device.nix { };

    nsm = final.callPackage (defaultPackageFrom nsm) { };
    todo = final.callPackage (defaultPackageFrom todo) { };
    collect-garbage = final.callPackage ./pkgs/collect-garbage.nix { };
    download-nixpkgs-cache-index = final.callPackage ./pkgs/download-nixpkgs-cache-index.nix { };
    export-aws-credentials = final.callPackage ./pkgs/export-aws-credentials.nix { };
    git-sync = final.callPackage ./pkgs/git-sync.nix { };
    gpg-import-keys = final.callPackage ./pkgs/gpg-import-keys.nix { };
    mmfm = final.callPackage ./pkgs/mmfm.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    prune-docker = final.callPackage ./pkgs/prune-docker.nix { };
    twx = final.callPackage ./pkgs/twx.nix { };
    lib = prev.lib // lib;
  };

  modifications = final: prev: {
    twm = final.callPackage (defaultPackageFrom twm) { };
    neovim = final.callPackage (defaultPackageFrom neovim-nightly) { };
    lib = prev.lib // lib;
  };

  unstable-packages = final: _prev: {
    unstable = import nixpkgs-unstable {
      inherit (final) system hostPlatform config;
    };
  };

  nur = inputs.nur.overlay;
}
