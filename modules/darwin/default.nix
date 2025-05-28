{ lib, ... }:

with lib;

{
  imports = [
    ./console.nix
    ./homebrew.nix
    ./networking.nix
    ./system.nix
    ./users.nix
  ];

  config = {
    system.stateVersion = 5;
    nix = {
      useDaemon = true;
      gc = {
        automatic = true;
        interval = { Weekday = 0; Hour = 0; Minute = 0; };
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
      registry = mapAttrs (_: value: { flake = value; }) inputs;
      settings = {
        experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
        connect-timeout = 5;
        log-lines = mkDefault 25;
        fallback = true;
        warn-dirty = true;
        keep-going = true;
        keep-outputs = true;
        keep-derivations = true;
        auto-optimise-store = true;
        builders-use-substitutes = true;
        trusted-users = [ "dom" "nixremote" "root" "@wheel" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "dominicegginton.cachix.org-1:P8AQ3itMEVevMqAzCKiPyvJ6l1a9NVaFPAXJqb9mAaY="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://dominicegginton.cachix.org"
        ];
      };
    };
  };
}
