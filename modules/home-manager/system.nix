{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isDarwin;
  cfg = config.modules.system;
in {
  options.modules.system = {
    stateVersion = mkOption {
      type = types.str;
      description = "The version of the state";
    };

    username = mkOption {
      type = types.str;
      description = "The username of the user";
    };
  };

  config = {
    home = {
      stateVersion = cfg.stateVersion;
      username = cfg.username;
      homeDirectory =
        if isDarwin
        then "/Users/${cfg.username}"
        else "/home/${cfg.username}";
      sessionPath = ["$HOME/.local/bin"];
      activation.report-changes = config.lib.dag.entryAnywhere ''
        ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
      '';
    };

    nix = {
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
      package = pkgs.unstable.nix;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        keep-outputs = true;
        keep-derivations = true;
        warn-dirty = false;
        trusted-users = ["root" "@wheel"];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
        ];

        # Set auto optimise store to false on darwin
        # to avoid the issue with the store being locked
        # and causing nix to hang when trying to build
        # a derivation. This is a temporary fix until
        # the issue is resolved in nix.
        # SEE: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store =
          if isDarwin
          then false
          else true;
      };
    };

    # Enable home-manager
    programs.home-manager.enable = true;
  };
}
