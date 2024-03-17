{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux isDarwin;
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

    # TODO move nix config into shared module
    nix = {
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
      package = pkgs.nix;
      settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
        keep-outputs = true;
        keep-derivations = true;
        warn-dirty = false;
      };
    };

    # Enable home-manager
    programs.home-manager.enable = true;
  };
}
