{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.system;
in {
  options.modules.system = {
    stateVersion = mkOption {
      type = types.str;
      default = "20.09";
      description = "The state version to use for the system";
    };
  };

  config = {
    system = {
      # Activation script to diff the current
      # system with the new system configuration.
      activationScripts.diff = {
        supportsDryActivation = true;
        text = ''
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        '';
      };

      stateVersion = cfg.stateVersion;
    };
  };
}
