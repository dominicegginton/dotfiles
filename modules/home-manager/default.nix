{ config
, lib
, pkgs
, ...
}:

let
  inherit (pkgs.stdenv) isDarwin;

  cfg = config.modules.system;

  # diff the old - new generations
  reportChanges = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
in

with lib;

{
  imports = [
    ./console
    ./desktop
    ./services
  ];

  options.modules.system = {
    stateVersion = mkOption { type = types.str; };
    username = mkOption { type = types.str; };
  };

  config = {
    home = {
      stateVersion = cfg.stateVersion;
      username = cfg.username;
      homeDirectory =
        if isDarwin
        then "/Users/${cfg.username}"
        else "/home/${cfg.username}";
      sessionPath = [ "$HOME/.local/bin" ];
      activation.report-changes = reportChanges;
    };
  };
}
