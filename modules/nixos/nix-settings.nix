{ inputs, config, lib, pkgs, ... }:

with lib;

{
  config = {
    nix = {
      package = pkgs.unstable.nix;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      optimise.automatic = mkDefault true;
      registry = mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = {
        experimental-features = [
          "auto-allocate-uids"
          "configurable-impure-env"
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        connect-timeout = 5;
        log-lines = 25;
        fallback = true;
        warn-dirty = true;
        keep-going = true;
        keep-outputs = false;
        keep-derivations = false;
        auto-optimise-store = true;
        builders-use-substitutes = true;
        substituters = [
          "https://cache.nixos.org"
          "https://dominicegginton.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "dominicegginton.cachix.org-1:P8AQ3itMEVevMqAzCKiPyvJ6l1a9NVaFPAXJqb9mAaY="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        ];

        min-free = "8G";
        max-free = "10G";
        min-free-check-interval = 1;
        trusted-users = [ "dom" "root" "@wheel" ];
      };
    };
  };
}
