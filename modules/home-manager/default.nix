{ config
, lib
, pkgs
, stateVersion
, username
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

  config = {
    home = {
      inherit stateVersion username;
      homeDirectory =
        if isDarwin
        then "/Users/${username}"
        else "/home/${username}";
      sessionPath = [ "$HOME/.local/bin" ];
      activation.report-changes = reportChanges;
    };
  };
}
