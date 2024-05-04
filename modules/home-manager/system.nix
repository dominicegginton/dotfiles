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
    stateVersion = mkOption {type = types.str;};
    username = mkOption {type = types.str;};
  };

  config = rec {
    home = rec {
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
  };
}
