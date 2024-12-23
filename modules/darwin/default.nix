{ inputs, config, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./console.nix
    ./homebrew.nix
    ./home-manager.nix
    ./networking.nix
    ./system.nix
    ./users.nix
  ];

  config = {
    system.stateVersion = 5;
    nix = {
      useDaemon = true;
      gc.automatic = true;
      optimise.automatic = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        log-lines = 100;
        connect-timeout = 30;
        fallback = true;
        warn-dirty = true;
        keep-going = true;
        keep-outputs = true;
        keep-derivations = true;
        # Set auto optimise store to false on darwin
        # to avoid the issue with the store being locked
        # and causing nix to hang when trying to build
        # a derivation. This is a temporary fix until
        # the issue is resolved in nix.
        # SEE: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = false;
        min-free = 10000000000;
        max-free = 20000000000;
        trusted-users = [ "root" "nixremote" "@wheel" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "dominicegginton.cachix.org-1:P8AQ3itMEVevMqAzCKiPyvJ6l1a9NVaFPAXJqb9mAaY="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://dominicegginton.cachix.org"
        ];
      };
    };
  };
}
